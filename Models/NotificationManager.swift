//
//  NotificationManager.swift
//  OrangeReminder
//
//  通知管理器 - 支持多种提醒方式
//

import Foundation
import UserNotifications
import SwiftUI
import AVFoundation

class NotificationManager: ObservableObject {
    @Published var notificationStyle: NotificationStyle = .timeSensitive
    @Published var showInAppAlert: Bool = false
    @Published var alertMessage: String = ""

    private var audioPlayer: AVAudioPlayer?

    enum NotificationStyle: String, CaseIterable, Identifiable {
        case standard = "标准通知"
        case timeSensitive = "时间关键通知"
        case inAppAlert = "应用内强制弹窗"
        case sound = "持续声音提醒"
        case combined = "组合提醒"

        var id: String { rawValue }

        var description: String {
            switch self {
            case .standard:
                return "普通推送通知，可以被静音"
            case .timeSensitive:
                return "突破专注模式的时间关键通知"
            case .inAppAlert:
                return "应用内全屏弹窗，必须手动关闭"
            case .sound:
                return "持续播放提醒声音，直到用户响应"
            case .combined:
                return "组合使用多种提醒方式"
            }
        }
    }

    init() {
        setupNotificationObservers()
        loadSettings()
    }

    // MARK: - Public Methods
    func sendReminderNotification(message: String, isUrgent: Bool = true) {
        switch notificationStyle {
        case .standard:
            sendStandardNotification(message: message)
        case .timeSensitive:
            sendTimeSensitiveNotification(message: message)
        case .inAppAlert:
            showInAppAlertView(message: message)
        case .sound:
            playContinuousSound()
            sendStandardNotification(message: message)
        case .combined:
            sendCombinedReminder(message: message)
        }
    }

    // MARK: - Notification Methods

    // 1. 标准通知
    private func sendStandardNotification(message: String) {
        let content = UNMutableNotificationContent()
        content.title = "⏰ 休息提醒"
        content.body = message
        content.sound = .default
        content.badge = 1

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil // 立即发送
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("发送通知失败: \(error.localizedDescription)")
            }
        }
    }

    // 2. 时间关键通知（iOS 15+，可突破专注模式）
    private func sendTimeSensitiveNotification(message: String) {
        let content = UNMutableNotificationContent()
        content.title = "🚨 重要提醒"
        content.body = message
        content.sound = .defaultCritical // 使用关键声音
        content.interruptionLevel = .timeSensitive // 时间关键级别
        content.badge = 1

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("发送时间关键通知失败: \(error.localizedDescription)")
            }
        }
    }

    // 3. 应用内弹窗
    private func showInAppAlertView(message: String) {
        DispatchQueue.main.async {
            self.alertMessage = message
            self.showInAppAlert = true

            // 同时发送通知以防应用在后台
            self.sendTimeSensitiveNotification(message: message)
        }
    }

    // 4. 持续声音提醒
    private func playContinuousSound() {
        // 使用系统声音或自定义音频文件
        // 这里使用振动和系统声音的组合
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)

        // 创建一个重复的本地通知来模拟持续提醒
        scheduleRepeatingNotifications()
    }

    private func scheduleRepeatingNotifications() {
        // 每分钟发送一次通知，共发送5次
        for i in 1...5 {
            let content = UNMutableNotificationContent()
            content.title = "⚠️ 请注意休息"
            content.body = "您已使用手机过长时间，请立即休息！"
            content.sound = .defaultCritical
            content.interruptionLevel = .timeSensitive

            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(i * 60), repeats: false)

            let request = UNNotificationRequest(
                identifier: "repeating-\(i)",
                content: content,
                trigger: trigger
            )

            UNUserNotificationCenter.current().add(request)
        }
    }

    // 5. 组合提醒
    private func sendCombinedReminder(message: String) {
        // 同时使用多种提醒方式
        sendTimeSensitiveNotification(message: message)
        showInAppAlertView(message: message)
        playContinuousSound()
    }

    // MARK: - Helper Methods
    func dismissInAppAlert() {
        showInAppAlert = false
        stopSound()
    }

    func stopSound() {
        audioPlayer?.stop()
        audioPlayer = nil

        // 取消所有待发送的重复通知
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    private func setupNotificationObservers() {
        // 监听屏幕时间限制达到的通知
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleScreenTimeLimitReached),
            name: NSNotification.Name("ScreenTimeLimitReached"),
            object: nil
        )

        // 监听每小时提醒
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleHourlyUpdate),
            name: NSNotification.Name("ScreenTimeHourlyUpdate"),
            object: nil
        )
    }

    @objc private func handleScreenTimeLimitReached(notification: Notification) {
        guard let totalTime = notification.userInfo?["totalTime"] as? TimeInterval else { return }

        let hours = Int(totalTime / 3600)
        let minutes = Int((totalTime.truncatingRemainder(dividingBy: 3600)) / 60)

        let message = "您今天已使用手机 \(hours) 小时 \(minutes) 分钟，已达到设定限制。请立即休息，保护您的眼睛和身体健康！"

        sendReminderNotification(message: message, isUrgent: true)
    }

    @objc private func handleHourlyUpdate(notification: Notification) {
        guard let hours = notification.userInfo?["hours"] as? Int else { return }

        let message = "您已连续使用手机 \(hours) 小时，建议休息一下。"

        sendReminderNotification(message: message, isUrgent: false)
    }

    private func loadSettings() {
        if let savedStyle = UserDefaults.standard.string(forKey: "notificationStyle"),
           let style = NotificationStyle(rawValue: savedStyle) {
            notificationStyle = style
        }
    }

    func saveSettings() {
        UserDefaults.standard.set(notificationStyle.rawValue, forKey: "notificationStyle")
    }
}
