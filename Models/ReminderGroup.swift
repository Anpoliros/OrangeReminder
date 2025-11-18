//
//  ReminderGroup.swift
//  OrangeReminder
//
//  提醒组数据模型
//

import Foundation
import SwiftUI

// MARK: - 提醒组
struct ReminderGroup: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var name: String
    var isEnabled: Bool = true
    var icon: String = "bell.fill"
    var color: String = "orange"

    // 基础设置
    var timeLimitMinutes: Int = 60 // 使用时间限制（分钟）
    var notificationStyle: NotificationStyle = .timeSensitive

    // 白名单应用（这些应用不计入时间）
    var whitelistedApps: [String] = []

    // 复杂情景设置
    var hasComplexScenario: Bool = false
    var scenario: UsageScenario?

    // 统计
    var createdAt: Date = Date()
    var lastUsedAt: Date?

    enum NotificationStyle: String, Codable, CaseIterable {
        case standard = "标准通知"
        case timeSensitive = "时间关键通知"
        case inAppAlert = "应用内强制弹窗"
        case sound = "持续声音提醒"
        case combined = "组合提醒"
    }
}

// MARK: - 使用情景（番茄钟式）
struct UsageScenario: Codable, Equatable {
    var id: UUID = UUID()
    var sessions: [SessionPeriod] = []
    var repeatCycle: Bool = true // 是否循环重复

    // 当前进度
    var currentSessionIndex: Int = 0
    var sessionStartTime: Date?

    mutating func reset() {
        currentSessionIndex = 0
        sessionStartTime = nil
    }

    mutating func nextSession() {
        currentSessionIndex += 1
        if repeatCycle && currentSessionIndex >= sessions.count {
            currentSessionIndex = 0
        }
        sessionStartTime = Date()
    }

    var currentSession: SessionPeriod? {
        guard currentSessionIndex < sessions.count else { return nil }
        return sessions[currentSessionIndex]
    }

    var hasMoreSessions: Bool {
        if repeatCycle { return true }
        return currentSessionIndex < sessions.count
    }
}

// MARK: - 时间段
struct SessionPeriod: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var durationMinutes: Int
    var type: SessionType
    var name: String

    enum SessionType: String, Codable {
        case work = "工作"
        case shortBreak = "短休息"
        case longBreak = "长休息"

        var icon: String {
            switch self {
            case .work: return "laptopcomputer"
            case .shortBreak: return "cup.and.saucer.fill"
            case .longBreak: return "bed.double.fill"
            }
        }

        var color: Color {
            switch self {
            case .work: return .blue
            case .shortBreak: return .green
            case .longBreak: return .purple
            }
        }
    }
}

// MARK: - 预设模板
extension ReminderGroup {
    static let templates: [ReminderGroup] = [
        // 标准模式
        ReminderGroup(
            name: "标准模式",
            icon: "clock.fill",
            color: "blue",
            timeLimitMinutes: 60,
            notificationStyle: .timeSensitive
        ),

        // 工作模式
        ReminderGroup(
            name: "工作模式",
            icon: "briefcase.fill",
            color: "orange",
            timeLimitMinutes: 120,
            notificationStyle: .inAppAlert,
            whitelistedApps: ["生产力工具", "办公软件"],
            hasComplexScenario: true,
            scenario: UsageScenario(
                sessions: [
                    SessionPeriod(durationMinutes: 40, type: .work, name: "专注工作"),
                    SessionPeriod(durationMinutes: 5, type: .shortBreak, name: "短暂休息"),
                    SessionPeriod(durationMinutes: 40, type: .work, name: "继续工作"),
                    SessionPeriod(durationMinutes: 15, type: .longBreak, name: "长休息")
                ],
                repeatCycle: true
            )
        ),

        // 学习模式
        ReminderGroup(
            name: "学习模式",
            icon: "book.fill",
            color: "green",
            timeLimitMinutes: 90,
            notificationStyle: .combined,
            whitelistedApps: ["学习应用", "阅读工具"],
            hasComplexScenario: true,
            scenario: UsageScenario(
                sessions: [
                    SessionPeriod(durationMinutes: 25, type: .work, name: "学习"),
                    SessionPeriod(durationMinutes: 5, type: .shortBreak, name: "休息"),
                    SessionPeriod(durationMinutes: 25, type: .work, name: "学习"),
                    SessionPeriod(durationMinutes: 5, type: .shortBreak, name: "休息"),
                    SessionPeriod(durationMinutes: 25, type: .work, name: "学习"),
                    SessionPeriod(durationMinutes: 15, type: .longBreak, name: "长休息")
                ],
                repeatCycle: true
            )
        ),

        // 睡前模式
        ReminderGroup(
            name: "睡前模式",
            icon: "moon.fill",
            color: "purple",
            timeLimitMinutes: 30,
            notificationStyle: .combined,
            whitelistedApps: ["冥想应用", "睡眠音乐"]
        ),

        // 自由模式
        ReminderGroup(
            name: "自由模式",
            icon: "hand.raised.fill",
            color: "red",
            timeLimitMinutes: 180,
            notificationStyle: .standard
        )
    ]
}
