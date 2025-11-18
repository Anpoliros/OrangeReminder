//
//  ContentView.swift
//  OrangeReminder
//
//  主界面
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var screenTimeTracker: ScreenTimeTracker
    @EnvironmentObject var notificationManager: NotificationManager
    @State private var showSettings = false

    var body: some View {
        ZStack {
            // 主内容
            NavigationView {
                ScrollView {
                    VStack(spacing: 30) {
                        // MARK: - 顶部图标
                        Image(systemName: screenTimeTracker.isOverLimit ? "exclamationmark.triangle.fill" : "clock.fill")
                            .font(.system(size: 80))
                            .foregroundColor(screenTimeTracker.isOverLimit ? .red : .orange)
                            .padding(.top, 40)

                        // MARK: - 使用时间显示
                        VStack(spacing: 10) {
                            Text("今日使用时间")
                                .font(.headline)
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

                        // MARK: - 进度条
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("使用进度")
                                    .font(.headline)
                                Spacer()
                                Text("\(Int(min(100, (screenTimeTracker.currentTotalTime / screenTimeTracker.dailyLimit) * 100)))%")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                            }

                            ProgressView(value: min(1.0, screenTimeTracker.currentTotalTime / screenTimeTracker.dailyLimit))
                                .progressViewStyle(LinearProgressViewStyle(tint: progressColor))
                                .scaleEffect(x: 1, y: 2, anchor: .center)

                            HStack {
                                Text("0h")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text("限制: \(formatTime(screenTimeTracker.dailyLimit))")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.horizontal, 30)

                        // MARK: - 统计卡片
                        HStack(spacing: 15) {
                            StatCard(
                                icon: "target",
                                title: "每日限制",
                                value: formatTime(screenTimeTracker.dailyLimit),
                                color: .blue
                            )

                            StatCard(
                                icon: "bell.fill",
                                title: "提醒方式",
                                value: notificationManager.notificationStyle.rawValue,
                                color: .purple
                            )
                        }
                        .padding(.horizontal, 20)

                        // MARK: - 健康提示
                        VStack(alignment: .leading, spacing: 15) {
                            Text("💡 健康提示")
                                .font(.headline)

                            VStack(alignment: .leading, spacing: 10) {
                                HealthTip(icon: "eye", text: "每20分钟远眺20秒，保护视力")
                                HealthTip(icon: "figure.walk", text: "每小时起身活动，促进血液循环")
                                HealthTip(icon: "moon.fill", text: "睡前1小时避免使用手机")
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.orange.opacity(0.1))
                        )
                        .padding(.horizontal, 20)

                        Spacer(minLength: 30)
                    }
                    .padding(.bottom, 30)
                }
                .navigationTitle("OrangeReminder")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { showSettings = true }) {
                            Image(systemName: "gearshape.fill")
                                .font(.title3)
                        }
                    }
                }
            }

            // MARK: - 应用内全屏弹窗
            if notificationManager.showInAppAlert {
                InAppAlertView()
                    .environmentObject(notificationManager)
                    .transition(.move(edge: .bottom))
                    .zIndex(999)
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
                .environmentObject(screenTimeTracker)
                .environmentObject(notificationManager)
        }
    }

    // MARK: - Computed Properties
    private var progressColor: Color {
        let progress = screenTimeTracker.currentTotalTime / screenTimeTracker.dailyLimit
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

    // MARK: - Helper Methods
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = (Int(timeInterval) % 3600) / 60
        return String(format: "%dh %dm", hours, minutes)
    }
}

// MARK: - StatCard Component
struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)

            Text(value)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.gray.opacity(0.1))
        )
    }
}

// MARK: - HealthTip Component
struct HealthTip: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body)
                .foregroundColor(.orange)
                .frame(width: 24)

            Text(text)
                .font(.subheadline)
                .foregroundColor(.primary)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(ScreenTimeTracker())
        .environmentObject(NotificationManager())
}
