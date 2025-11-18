//
//  CurrentReminderView.swift
//  OrangeReminder
//
//  当前提醒Tab视图
//

import SwiftUI

struct CurrentReminderView: View {
    @EnvironmentObject var screenTimeTracker: EnhancedScreenTimeTracker
    @EnvironmentObject var groupManager: ReminderGroupManager
    @EnvironmentObject var notificationManager: NotificationManager

    @State private var showGroupPicker = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    // MARK: - 快捷开关
                    toggleSection

                    if groupManager.isTrackingEnabled {
                        // MARK: - 当前提醒组
                        activeGroupSection

                        // MARK: - 使用时间显示
                        timeDisplaySection

                        // MARK: - 进度条
                        progressSection

                        // MARK: - 情景模式
                        if let group = groupManager.activeGroup,
                           group.hasComplexScenario,
                           let scenario = group.scenario {
                            scenarioSection(scenario: scenario)
                        }

                        // MARK: - 统计卡片
                        statsSection

                        // MARK: - 快捷操作
                        quickActionsSection
                    } else {
                        disabledStateView
                    }
                }
                .padding()
            }
            .navigationTitle("OrangeReminder")
            .sheet(isPresented: $showGroupPicker) {
                GroupPickerSheet()
            }
        }
    }

    // MARK: - Toggle Section
    private var toggleSection: some View {
        HStack(spacing: 15) {
            Image(systemName: groupManager.isTrackingEnabled ? "play.circle.fill" : "pause.circle.fill")
                .font(.system(size: 50))
                .foregroundColor(groupManager.isTrackingEnabled ? .green : .gray)

            VStack(alignment: .leading, spacing: 5) {
                Text(groupManager.isTrackingEnabled ? "追踪已开启" : "追踪已暂停")
                    .font(.title2)
                    .fontWeight(.bold)

                Text(groupManager.isTrackingEnabled ? "正在监控使用时间" : "点击开关恢复追踪")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Toggle("", isOn: Binding(
                get: { groupManager.isTrackingEnabled },
                set: { newValue in
                    groupManager.toggleTracking()
                    if newValue {
                        screenTimeTracker.startTracking()
                    } else {
                        screenTimeTracker.stopTracking()
                    }
                }
            ))
            .labelsHidden()
            .scaleEffect(1.2)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.gray.opacity(0.1))
        )
    }

    // MARK: - Active Group Section
    private var activeGroupSection: some View {
        Button(action: { showGroupPicker = true }) {
            HStack {
                if let group = groupManager.activeGroup {
                    Image(systemName: group.icon)
                        .font(.title2)
                        .foregroundColor(Color(group.color))
                        .frame(width: 50, height: 50)
                        .background(
                            Circle()
                                .fill(Color(group.color).opacity(0.2))
                        )

                    VStack(alignment: .leading, spacing: 5) {
                        Text(group.name)
                            .font(.headline)
                            .foregroundColor(.primary)

                        Text("\(group.timeLimitMinutes) 分钟限制 • \(group.notificationStyle.rawValue)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                } else {
                    Text("请选择提醒组")
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.orange.opacity(0.1))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }

    // MARK: - Time Display Section
    private var timeDisplaySection: some View {
        VStack(spacing: 15) {
            Image(systemName: screenTimeTracker.isOverLimit ? "exclamationmark.triangle.fill" : "clock.fill")
                .font(.system(size: 70))
                .foregroundColor(screenTimeTracker.isOverLimit ? .red : .orange)

            VStack(spacing: 5) {
                Text("今日使用时间")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Text(formatTime(screenTimeTracker.currentTotalTime))
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(screenTimeTracker.isOverLimit ? .red : .primary)

                if screenTimeTracker.isOverLimit {
                    Text("⚠️ 已超出限制")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.red)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.red.opacity(0.1))
                        )
                } else {
                    HStack {
                        Text("剩余:")
                        Text(formatTime(screenTimeTracker.remainingTime))
                            .fontWeight(.semibold)
                    }
                    .font(.title3)
                    .foregroundColor(.green)
                }
            }
        }
    }

    // MARK: - Progress Section
    private var progressSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("使用进度")
                    .font(.headline)
                Spacer()
                Text("\(Int(screenTimeTracker.progress * 100))%")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }

            ProgressView(value: screenTimeTracker.progress)
                .progressViewStyle(LinearProgressViewStyle(tint: progressColor))
                .scaleEffect(x: 1, y: 2, anchor: .center)

            if let group = groupManager.activeGroup {
                HStack {
                    Text("0分")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(group.timeLimitMinutes) 分钟")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.gray.opacity(0.05))
        )
    }

    // MARK: - Scenario Section
    private func scenarioSection(scenario: UsageScenario) -> some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "figure.run")
                    .font(.title3)
                Text("情景模式")
                    .font(.headline)
                Spacer()
            }

            if let currentSession = screenTimeTracker.currentScenarioSession {
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: currentSession.type.icon)
                            .foregroundColor(currentSession.type.color)
                        Text(currentSession.name)
                            .font(.title3)
                            .fontWeight(.semibold)
                        Spacer()
                        Text(formatTime(screenTimeTracker.scenarioRemainingTime))
                            .font(.headline)
                            .foregroundColor(currentSession.type.color)
                    }

                    ProgressView(value: screenTimeTracker.scenarioProgress)
                        .progressViewStyle(LinearProgressViewStyle(tint: currentSession.type.color))
                        .scaleEffect(x: 1, y: 1.5, anchor: .center)

                    HStack(spacing: 10) {
                        Button(action: {
                            screenTimeTracker.skipToNextSession()
                        }) {
                            Label("跳过", systemImage: "forward.fill")
                                .font(.caption)
                                .padding(.horizontal, 15)
                                .padding(.vertical, 8)
                                .background(Color.blue.opacity(0.1))
                                .foregroundColor(.blue)
                                .cornerRadius(8)
                        }

                        Button(action: {
                            screenTimeTracker.restartScenario()
                        }) {
                            Label("重新开始", systemImage: "arrow.clockwise")
                                .font(.caption)
                                .padding(.horizontal, 15)
                                .padding(.vertical, 8)
                                .background(Color.orange.opacity(0.1))
                                .foregroundColor(.orange)
                                .cornerRadius(8)
                        }
                    }
                }
            } else {
                Button(action: {
                    if let group = groupManager.activeGroup {
                        groupManager.startScenario(for: group.id)
                        screenTimeTracker.startTracking()
                    }
                }) {
                    HStack {
                        Image(systemName: "play.circle.fill")
                        Text("开始情景模式")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.blue.opacity(0.05))
        )
    }

    // MARK: - Stats Section
    private var statsSection: some View {
        HStack(spacing: 15) {
            if let group = groupManager.activeGroup {
                StatCard(
                    icon: "target",
                    title: "每日限制",
                    value: "\(group.timeLimitMinutes)分钟",
                    color: .blue
                )

                StatCard(
                    icon: "bell.fill",
                    title: "提醒方式",
                    value: group.notificationStyle.rawValue,
                    color: .purple
                )
            }
        }
    }

    // MARK: - Quick Actions
    private var quickActionsSection: some View {
        VStack(spacing: 12) {
            Text("快捷操作")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 12) {
                QuickActionButton(
                    icon: "arrow.counterclockwise",
                    title: "重置",
                    color: .orange
                ) {
                    screenTimeTracker.resetDailyTime()
                }

                QuickActionButton(
                    icon: "bell.badge",
                    title: "测试提醒",
                    color: .purple
                ) {
                    notificationManager.sendReminderNotification(
                        message: "这是一条测试提醒",
                        isUrgent: true
                    )
                }
            }
        }
    }

    // MARK: - Disabled State
    private var disabledStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "pause.circle")
                .font(.system(size: 80))
                .foregroundColor(.gray)

            Text("追踪已暂停")
                .font(.title2)
                .fontWeight(.bold)

            Text("打开上方开关以恢复追踪")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.top, 100)
    }

    // MARK: - Helper Methods
    private var progressColor: Color {
        let progress = screenTimeTracker.progress
        if progress >= 1.0 {
            return .red
        } else if progress >= 0.8 {
            return .orange
        } else if progress >= 0.5 {
            return .yellow
        } else {
            return .green
        }
    }

    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = (Int(timeInterval) % 3600) / 60
        if hours > 0 {
            return String(format: "%dh %dm", hours, minutes)
        } else {
            return String(format: "%dm", minutes)
        }
    }
}

// MARK: - Quick Action Button
struct QuickActionButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                Text(title)
                    .font(.caption)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(color.opacity(0.1))
            .foregroundColor(color)
            .cornerRadius(12)
        }
    }
}

// MARK: - Group Picker Sheet
struct GroupPickerSheet: View {
    @EnvironmentObject var groupManager: ReminderGroupManager
    @EnvironmentObject var screenTimeTracker: EnhancedScreenTimeTracker
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            List(groupManager.groups) { group in
                Button(action: {
                    groupManager.activateGroup(group)
                    screenTimeTracker.startTracking()
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: group.icon)
                            .foregroundColor(Color(group.color))
                            .frame(width: 40)

                        VStack(alignment: .leading) {
                            Text(group.name)
                                .font(.headline)
                            Text("\(group.timeLimitMinutes) 分钟")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        if groupManager.activeGroupId == group.id {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        }
                    }
                }
            }
            .navigationTitle("选择提醒组")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    let groupManager = ReminderGroupManager()
    let whitelistManager = AppWhitelistManager()
    let tracker = EnhancedScreenTimeTracker(groupManager: groupManager, whitelistManager: whitelistManager)
    let notificationManager = NotificationManager()

    return CurrentReminderView()
        .environmentObject(tracker)
        .environmentObject(groupManager)
        .environmentObject(notificationManager)
}
