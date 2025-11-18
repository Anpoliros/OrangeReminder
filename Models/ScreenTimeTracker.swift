//
//  ScreenTimeTracker.swift
//  OrangeReminder
//
//  屏幕使用时间跟踪器
//

import Foundation
import SwiftUI
import Combine

class ScreenTimeTracker: ObservableObject {
    // MARK: - Published Properties
    @Published var totalScreenTime: TimeInterval = 0 // 总屏幕时间（秒）
    @Published var sessionStartTime: Date?
    @Published var isTracking: Bool = false
    @Published var dailyLimit: TimeInterval = 3600 // 默认1小时限制
    @Published var shouldShowAlert: Bool = false

    // MARK: - Private Properties
    private var timer: Timer?
    private var backgroundEntryTime: Date?
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization
    init() {
        setupNotificationObservers()
        loadSettings()
        loadTodayScreenTime()
    }

    // MARK: - Public Methods
    func startTracking() {
        guard !isTracking else { return }

        isTracking = true
        sessionStartTime = Date()

        // 每分钟更新一次
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            self?.updateScreenTime()
        }

        print("开始跟踪屏幕时间")
    }

    func stopTracking() {
        isTracking = false
        timer?.invalidate()
        timer = nil

        if let startTime = sessionStartTime {
            let sessionDuration = Date().timeIntervalSince(startTime)
            totalScreenTime += sessionDuration
            saveScreenTime()
        }

        sessionStartTime = nil
        print("停止跟踪屏幕时间")
    }

    func resetDailyTime() {
        totalScreenTime = 0
        saveScreenTime()
    }

    func updateDailyLimit(_ newLimit: TimeInterval) {
        dailyLimit = newLimit
        UserDefaults.standard.set(newLimit, forKey: "dailyLimit")
    }

    // MARK: - Private Methods
    private func setupNotificationObservers() {
        // 应用进入后台
        NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)
            .sink { [weak self] _ in
                self?.handleAppWillResignActive()
            }
            .store(in: &cancellables)

        // 应用进入前台
        NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
            .sink { [weak self] _ in
                self?.handleAppDidBecomeActive()
            }
            .store(in: &cancellables)
    }

    private func handleAppWillResignActive() {
        backgroundEntryTime = Date()

        if let startTime = sessionStartTime {
            let sessionDuration = Date().timeIntervalSince(startTime)
            totalScreenTime += sessionDuration
            saveScreenTime()
            sessionStartTime = nil
        }
    }

    private func handleAppDidBecomeActive() {
        // 检查是否是新的一天
        checkAndResetIfNewDay()

        // 重新开始跟踪
        if isTracking {
            sessionStartTime = Date()
        }
    }

    private func updateScreenTime() {
        guard let startTime = sessionStartTime else { return }

        let currentSessionTime = Date().timeIntervalSince(startTime)
        let currentTotal = totalScreenTime + currentSessionTime

        // 检查是否超过限制
        if currentTotal >= dailyLimit {
            triggerReminder()
        }

        // 每小时提醒
        let hours = Int(currentTotal / 3600)
        let previousHours = Int(totalScreenTime / 3600)
        if hours > previousHours {
            triggerHourlyReminder(hours: hours)
        }
    }

    private func triggerReminder() {
        shouldShowAlert = true

        // 发送通知
        NotificationCenter.default.post(
            name: NSNotification.Name("ScreenTimeLimitReached"),
            object: nil,
            userInfo: ["totalTime": totalScreenTime + (sessionStartTime.map { Date().timeIntervalSince($0) } ?? 0)]
        )
    }

    private func triggerHourlyReminder(hours: Int) {
        NotificationCenter.default.post(
            name: NSNotification.Name("ScreenTimeHourlyUpdate"),
            object: nil,
            userInfo: ["hours": hours]
        )
    }

    private func checkAndResetIfNewDay() {
        let lastSaveDate = UserDefaults.standard.object(forKey: "lastSaveDate") as? Date ?? Date()
        let calendar = Calendar.current

        if !calendar.isDateInToday(lastSaveDate) {
            resetDailyTime()
        }
    }

    private func saveScreenTime() {
        UserDefaults.standard.set(totalScreenTime, forKey: "totalScreenTime")
        UserDefaults.standard.set(Date(), forKey: "lastSaveDate")
    }

    private func loadTodayScreenTime() {
        let lastSaveDate = UserDefaults.standard.object(forKey: "lastSaveDate") as? Date ?? Date()
        let calendar = Calendar.current

        if calendar.isDateInToday(lastSaveDate) {
            totalScreenTime = UserDefaults.standard.double(forKey: "totalScreenTime")
        } else {
            totalScreenTime = 0
        }
    }

    private func loadSettings() {
        let savedLimit = UserDefaults.standard.double(forKey: "dailyLimit")
        if savedLimit > 0 {
            dailyLimit = savedLimit
        }
    }

    // MARK: - Computed Properties
    var currentTotalTime: TimeInterval {
        var total = totalScreenTime
        if let startTime = sessionStartTime {
            total += Date().timeIntervalSince(startTime)
        }
        return total
    }

    var remainingTime: TimeInterval {
        return max(0, dailyLimit - currentTotalTime)
    }

    var isOverLimit: Bool {
        return currentTotalTime >= dailyLimit
    }
}
