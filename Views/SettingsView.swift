//
//  SettingsView.swift
//  OrangeReminder
//
//  设置界面
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var screenTimeTracker: ScreenTimeTracker
    @EnvironmentObject var notificationManager: NotificationManager
    @Environment(\.dismiss) var dismiss

    @State private var selectedHours: Int = 1
    @State private var selectedMinutes: Int = 0

    var body: some View {
        NavigationView {
            Form {
                // MARK: - 时间限制设置
                Section {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("每日使用限制")
                            .font(.headline)

                        HStack {
                            Picker("小时", selection: $selectedHours) {
                                ForEach(0...12, id: \.self) { hour in
                                    Text("\(hour) 小时").tag(hour)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(maxWidth: .infinity)

                            Picker("分钟", selection: $selectedMinutes) {
                                ForEach(0...59, id: \.self) { minute in
                                    if minute % 5 == 0 {
                                        Text("\(minute) 分钟").tag(minute)
                                    }
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(maxWidth: .infinity)
                        }
                        .frame(height: 150)

                        Text("当前限制: \(formatTime(screenTimeTracker.dailyLimit))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text("使用限制")
                }

                // MARK: - 提醒方式设置
                Section {
                    Picker("提醒方式", selection: $notificationManager.notificationStyle) {
                        ForEach(NotificationManager.NotificationStyle.allCases) { style in
                            Text(style.rawValue).tag(style)
                        }
                    }
                    .pickerStyle(.menu)

                    Text(notificationManager.notificationStyle.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.vertical, 5)

                } header: {
                    Text("提醒设置")
                } footer: {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("提醒方式说明:")
                            .font(.caption)
                            .fontWeight(.semibold)

                        Text("• 标准通知: 最基础的提醒方式")
                        Text("• 时间关键通知: 可突破专注模式")
                        Text("• 应用内强制弹窗: 全屏显示，必须手动关闭")
                        Text("• 持续声音提醒: 重复发送通知和振动")
                        Text("• 组合提醒: 同时使用多种方式（最强效果）")
                    }
                    .font(.caption2)
                    .foregroundColor(.secondary)
                }

                // MARK: - 测试功能
                Section {
                    Button(action: testNotification) {
                        HStack {
                            Image(systemName: "bell.badge")
                            Text("测试提醒")
                        }
                    }

                    Button(action: resetScreenTime) {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                            Text("重置今日使用时间")
                        }
                    }
                    .foregroundColor(.orange)

                } header: {
                    Text("测试与管理")
                }

                // MARK: - 关于
                Section {
                    HStack {
                        Text("应用版本")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("开发者")
                        Spacer()
                        Text("OrangeReminder Team")
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text("关于")
                }
            }
            .navigationTitle("设置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        saveSettings()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
            .onAppear {
                loadCurrentSettings()
            }
        }
    }

    // MARK: - Helper Methods
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = (Int(timeInterval) % 3600) / 60
        return "\(hours) 小时 \(minutes) 分钟"
    }

    private func loadCurrentSettings() {
        let totalSeconds = Int(screenTimeTracker.dailyLimit)
        selectedHours = totalSeconds / 3600
        selectedMinutes = (totalSeconds % 3600) / 60
    }

    private func saveSettings() {
        let totalSeconds = TimeInterval(selectedHours * 3600 + selectedMinutes * 60)
        screenTimeTracker.updateDailyLimit(totalSeconds)
        notificationManager.saveSettings()
    }

    private func testNotification() {
        notificationManager.sendReminderNotification(
            message: "这是一条测试提醒。如果您看到此消息，说明提醒功能正常工作。",
            isUrgent: true
        )
    }

    private func resetScreenTime() {
        screenTimeTracker.resetDailyTime()
    }
}

#Preview {
    SettingsView()
        .environmentObject(ScreenTimeTracker())
        .environmentObject(NotificationManager())
}
