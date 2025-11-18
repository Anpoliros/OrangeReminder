//
//  MainTabView.swift
//  OrangeReminder
//
//  主TabView界面
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var screenTimeTracker: EnhancedScreenTimeTracker
    @EnvironmentObject var groupManager: ReminderGroupManager
    @EnvironmentObject var whitelistManager: AppWhitelistManager
    @EnvironmentObject var notificationManager: NotificationManager
    @EnvironmentObject var iCloudSync: iCloudSyncManager

    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            // Tab 1: 当前提醒
            CurrentReminderView()
                .tabItem {
                    Label("当前提醒", systemImage: "clock.fill")
                }
                .tag(0)

            // Tab 2: 提醒组
            ReminderGroupsView()
                .tabItem {
                    Label("提醒组", systemImage: "square.grid.2x2.fill")
                }
                .tag(1)

            // Tab 3: 设置
            EnhancedSettingsView()
                .tabItem {
                    Label("设置", systemImage: "gearshape.fill")
                }
                .tag(2)
        }
        .accentColor(.orange)
    }
}

#Preview {
    let groupManager = ReminderGroupManager()
    let whitelistManager = AppWhitelistManager()
    let tracker = EnhancedScreenTimeTracker(groupManager: groupManager, whitelistManager: whitelistManager)
    let notificationManager = NotificationManager()
    let iCloudSync = iCloudSyncManager()

    return MainTabView()
        .environmentObject(tracker)
        .environmentObject(groupManager)
        .environmentObject(whitelistManager)
        .environmentObject(notificationManager)
        .environmentObject(iCloudSync)
}
