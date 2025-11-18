//
//  EnhancedSettingsView.swift
//  OrangeReminder
//
//  增强的设置视图 - 包含iCloud同步和白名单管理
//

import SwiftUI

struct EnhancedSettingsView: View {
    @EnvironmentObject var groupManager: ReminderGroupManager
    @EnvironmentObject var whitelistManager: AppWhitelistManager
    @EnvironmentObject var iCloudSync: iCloudSyncManager
    @EnvironmentObject var notificationManager: NotificationManager

    @State private var showWhitelistManager = false
    @State private var showiCloudInfo = false
    @State private var showResetAlert = false
    @State private var showImportAlert = false
    @State private var importMessage = ""

    var body: some View {
        NavigationView {
            Form {
                // MARK: - 快捷操作
                Section {
                    HStack {
                        Image(systemName: groupManager.isTrackingEnabled ? "play.circle.fill" : "pause.circle.fill")
                            .font(.title2)
                            .foregroundColor(groupManager.isTrackingEnabled ? .green : .gray)

                        VStack(alignment: .leading) {
                            Text(groupManager.isTrackingEnabled ? "追踪已开启" : "追踪已暂停")
                                .font(.headline)
                            Text("快捷开关")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        Toggle("", isOn: Binding(
                            get: { groupManager.isTrackingEnabled },
                            set: { _ in groupManager.toggleTracking() }
                        ))
                        .labelsHidden()
                    }
                } header: {
                    Text("快捷操作")
                }

                // MARK: - 应用白名单
                Section {
                    Button(action: { showWhitelistManager = true }) {
                        HStack {
                            Image(systemName: "checkmark.shield.fill")
                                .foregroundColor(.green)
                            Text("应用白名单")
                            Spacer()
                            Text("\(whitelistManager.whitelistedApps.count) 个")
                                .foregroundColor(.secondary)
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    }
                    .foregroundColor(.primary)
                } header: {
                    Text("白名单管理")
                } footer: {
                    Text("白名单中的应用不会计入使用时间")
                }

                // MARK: - iCloud同步
                Section {
                    // 同步状态
                    HStack {
                        Image(systemName: "icloud.fill")
                            .foregroundColor(.blue)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("iCloud同步")
                                .font(.headline)
                            if let lastSync = iCloudSync.lastSyncDate {
                                Text("上次同步: \(formatDate(lastSync))")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            } else {
                                Text("从未同步")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        Spacer()
                        if iCloudSync.isSyncing {
                            ProgressView()
                        }
                    }

                    // 导出到iCloud
                    Button(action: exportToiCloud) {
                        HStack {
                            Image(systemName: "arrow.up.doc.fill")
                            Text("备份到iCloud")
                            Spacer()
                        }
                    }
                    .disabled(iCloudSync.isSyncing)

                    // 从iCloud导入
                    Button(action: checkAndImportFromiCloud) {
                        HStack {
                            Image(systemName: "arrow.down.doc.fill")
                            Text("从iCloud恢复")
                            Spacer()
                        }
                    }
                    .disabled(iCloudSync.isSyncing)

                    // 同步状态信息
                    if case .failed(let error) = iCloudSync.syncStatus {
                        Text("错误: \(error.localizedDescription)")
                            .font(.caption)
                            .foregroundColor(.red)
                    } else if case .success = iCloudSync.syncStatus {
                        Text("✅ 同步成功")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                } header: {
                    Text("iCloud同步")
                } footer: {
                    Text("备份和恢复您的所有提醒组设置。需要在系统设置中启用iCloud Drive。")
                }

                // MARK: - 通知测试
                Section {
                    Button(action: testNotification) {
                        HStack {
                            Image(systemName: "bell.badge.fill")
                            Text("测试提醒")
                        }
                    }
                } header: {
                    Text("测试")
                }

                // MARK: - 数据管理
                Section {
                    Button(role: .destructive, action: { showResetAlert = true }) {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                            Text("重置所有设置")
                        }
                    }
                } header: {
                    Text("数据管理")
                } footer: {
                    Text("将恢复到默认设置，所有提醒组将被删除")
                }

                // MARK: - 关于
                Section {
                    HStack {
                        Text("应用版本")
                        Spacer()
                        Text("2.0.0")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("提醒组数量")
                        Spacer()
                        Text("\(groupManager.groups.count)")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("白名单应用")
                        Spacer()
                        Text("\(whitelistManager.whitelistedApps.count)")
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text("关于")
                }
            }
            .navigationTitle("设置")
            .sheet(isPresented: $showWhitelistManager) {
                WhitelistManagerView()
            }
            .alert("重置所有设置", isPresented: $showResetAlert) {
                Button("取消", role: .cancel) { }
                Button("重置", role: .destructive) {
                    groupManager.resetToDefaults()
                }
            } message: {
                Text("确定要重置所有设置吗？此操作无法撤销。")
            }
            .alert("从iCloud恢复", isPresented: $showImportAlert) {
                Button("确定", role: .cancel) { }
            } message: {
                Text(importMessage)
            }
        }
    }

    // MARK: - Helper Methods
    private func exportToiCloud() {
        iCloudSync.exportToiCloud(groupManager: groupManager, whitelistManager: whitelistManager)
    }

    private func checkAndImportFromiCloud() {
        iCloudSync.checkBackupExists { exists, date in
            if exists {
                iCloudSync.importFromiCloud(groupManager: groupManager, whitelistManager: whitelistManager) { success, message in
                    importMessage = message
                    showImportAlert = true
                }
            } else {
                importMessage = "未找到iCloud备份文件"
                showImportAlert = true
            }
        }
    }

    private func testNotification() {
        if let group = groupManager.activeGroup {
            notificationManager.sendReminderNotification(
                message: "这是一条测试提醒。当前使用的是 \(group.name) 提醒组。",
                isUrgent: true
            )
        } else {
            notificationManager.sendReminderNotification(
                message: "这是一条测试提醒。",
                isUrgent: true
            )
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

#Preview {
    let groupManager = ReminderGroupManager()
    let whitelistManager = AppWhitelistManager()
    let iCloudSync = iCloudSyncManager()
    let notificationManager = NotificationManager()

    return EnhancedSettingsView()
        .environmentObject(groupManager)
        .environmentObject(whitelistManager)
        .environmentObject(iCloudSync)
        .environmentObject(notificationManager)
}
