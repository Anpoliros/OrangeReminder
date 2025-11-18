//
//  OrangeReminderApp.swift
//  OrangeReminder
//
//  防止长时间使用手机的提醒应用
//

import SwiftUI
import UserNotifications

@main
struct OrangeReminderApp: App {
    @StateObject private var screenTimeTracker = ScreenTimeTracker()
    @StateObject private var notificationManager = NotificationManager()

    init() {
        // 请求通知权限
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge, .criticalAlert]) { granted, error in
            if granted {
                print("通知权限已获得")
            } else if let error = error {
                print("通知权限请求失败: \(error.localizedDescription)")
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(screenTimeTracker)
                .environmentObject(notificationManager)
                .onAppear {
                    screenTimeTracker.startTracking()
                }
        }
    }
}
