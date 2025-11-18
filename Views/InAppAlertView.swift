//
//  InAppAlertView.swift
//  OrangeReminder
//
//  应用内全屏弹窗视图 - 强制性提醒
//

import SwiftUI

struct InAppAlertView: View {
    @EnvironmentObject var notificationManager: NotificationManager
    @State private var pulseAnimation = false
    @State private var shakeAnimation = false
    @State private var countdown = 10 // 10秒倒计时才能关闭

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            // 半透明背景
            Color.black.opacity(0.8)
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 30) {
                // MARK: - 警告图标
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 100))
                    .foregroundColor(.red)
                    .scaleEffect(pulseAnimation ? 1.2 : 1.0)
                    .animation(
                        Animation.easeInOut(duration: 0.8)
                            .repeatForever(autoreverses: true),
                        value: pulseAnimation
                    )
                    .rotationEffect(.degrees(shakeAnimation ? -5 : 5))
                    .animation(
                        Animation.easeInOut(duration: 0.15)
                            .repeatForever(autoreverses: true),
                        value: shakeAnimation
                    )

                // MARK: - 提醒标题
                Text("⚠️ 休息提醒 ⚠️")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)

                // MARK: - 提醒消息
                Text(notificationManager.alertMessage)
                    .font(.title2)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .fixedSize(horizontal: false, vertical: true)

                // MARK: - 健康建议
                VStack(alignment: .leading, spacing: 15) {
                    Text("建议您:")
                        .font(.headline)
                        .foregroundColor(.orange)

                    VStack(alignment: .leading, spacing: 10) {
                        SuggestionRow(icon: "figure.walk", text: "站起来走动走动")
                        SuggestionRow(icon: "eye", text: "远眺窗外，放松眼睛")
                        SuggestionRow(icon: "cup.and.saucer.fill", text: "喝杯水，补充水分")
                        SuggestionRow(icon: "moon.zzz.fill", text: "如果是晚上，考虑准备休息")
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.white.opacity(0.1))
                )
                .padding(.horizontal, 40)

                // MARK: - 关闭按钮（倒计时）
                VStack(spacing: 10) {
                    if countdown > 0 {
                        Text("请认真阅读上述建议")
                            .font(.caption)
                            .foregroundColor(.gray)

                        Button(action: {}) {
                            HStack {
                                Image(systemName: "lock.fill")
                                Text("请等待 \(countdown) 秒")
                            }
                            .font(.headline)
                            .foregroundColor(.gray)
                            .padding(.horizontal, 40)
                            .padding(.vertical, 15)
                            .background(
                                RoundedRectangle(cornerRadius: 25)
                                    .fill(Color.gray.opacity(0.3))
                            )
                        }
                        .disabled(true)
                    } else {
                        Button(action: dismissAlert) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                Text("我知道了，现在就去休息")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 40)
                            .padding(.vertical, 15)
                            .background(
                                RoundedRectangle(cornerRadius: 25)
                                    .fill(
                                        LinearGradient(
                                            colors: [.orange, .red],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                            )
                        }
                        .shadow(color: .orange.opacity(0.5), radius: 10)
                        .scaleEffect(pulseAnimation ? 1.05 : 1.0)
                    }
                }
                .padding(.top, 20)
            }
            .padding(.vertical, 40)
        }
        .onAppear {
            pulseAnimation = true
            shakeAnimation = true
            countdown = 10
        }
        .onReceive(timer) { _ in
            if countdown > 0 {
                countdown -= 1
            }
        }
    }

    // MARK: - Helper Methods
    private func dismissAlert() {
        withAnimation {
            notificationManager.dismissInAppAlert()
        }
    }
}

// MARK: - SuggestionRow Component
struct SuggestionRow: View {
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
                .foregroundColor(.white)
        }
    }
}

#Preview {
    InAppAlertView()
        .environmentObject(NotificationManager())
}
