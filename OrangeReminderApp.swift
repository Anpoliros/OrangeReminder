//
//  OrangeReminderApp.swift
//  OrangeReminder
//
//  防止长时间使用手机的提醒应用 - 增强版
//

import SwiftUI
import UserNotifications
import WidgetKit

@main
struct OrangeReminderApp: App {
    // 管理器
    @StateObject private var groupManager = ReminderGroupManager()
    @StateObject private var whitelistManager = AppWhitelistManager()
    @StateObject private var notificationManager = NotificationManager()
    @StateObject private var iCloudSync = iCloudSyncManager()

    // 延迟初始化的跟踪器
    @StateObject private var screenTimeTracker: EnhancedScreenTimeTracker

    init() {
        // 请求通知权限
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge, .criticalAlert]) { granted, error in
            if granted {
                print("✅ 通知权限已获得")
            } else if let error = error {
                print("❌ 通知权限请求失败: \(error.localizedDescription)")
            }
        }

        // 初始化管理器
        let groupMgr = ReminderGroupManager()
        let whitelistMgr = AppWhitelistManager()

        // 创建跟踪器
        let tracker = EnhancedScreenTimeTracker(
            groupManager: groupMgr,
            whitelistManager: whitelistMgr
        )

        _groupManager = StateObject(wrappedValue: groupMgr)
        _whitelistManager = StateObject(wrappedValue: whitelistMgr)
        _screenTimeTracker = StateObject(wrappedValue: tracker)
        _notificationManager = StateObject(wrappedValue: NotificationManager())
        _iCloudSync = StateObject(wrappedValue: iCloudSyncManager())

        // 设置共享数据给Widget
        setupSharedData(groupManager: groupMgr)
    }

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(screenTimeTracker)
                .environmentObject(groupManager)
                .environmentObject(whitelistManager)
                .environmentObject(notificationManager)
                .environmentObject(iCloudSync)
                .onAppear {
                    if groupManager.isTrackingEnabled {
                        screenTimeTracker.startTracking()
                    }
                }
                .onChange(of: groupManager.isTrackingEnabled) { newValue in
                    // 更新Widget
                    WidgetCenter.shared.reloadAllTimelines()

                    // 保存到UserDefaults供Widget使用
                    if let sharedDefaults = UserDefaults(suiteName: "group.com.orangereminder.shared") {
                        sharedDefaults.set(newValue, forKey: "isTrackingEnabled")
                        sharedDefaults.synchronize()
                    }
                }
        }
    }

    // MARK: - Setup Shared Data
    private func setupSharedData(groupManager: ReminderGroupManager) {
        // 设置App Group共享数据
        if let sharedDefaults = UserDefaults(suiteName: "group.com.orangereminder.shared") {
            sharedDefaults.set(groupManager.isTrackingEnabled, forKey: "isTrackingEnabled")
            if let activeGroup = groupManager.activeGroup {
                sharedDefaults.set(activeGroup.name, forKey: "activeGroupName")
                sharedDefaults.set(activeGroup.icon, forKey: "activeGroupIcon")
            }
            sharedDefaults.synchronize()
        }
    }
}
