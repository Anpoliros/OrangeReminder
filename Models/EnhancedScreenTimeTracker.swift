//
//  EnhancedScreenTimeTracker.swift
//  OrangeReminder
//
//  增强的屏幕使用时间跟踪器 - 支持提醒组和白名单
//

import Foundation
import SwiftUI
import Combine

class EnhancedScreenTimeTracker: ObservableObject {
    // MARK: - Published Properties
    @Published var totalScreenTime: TimeInterval = 0
    @Published var sessionStartTime: Date?
    @Published var isTracking: Bool = false
    @Published var shouldShowAlert: Bool = false
    @Published var currentScenarioSession: SessionPeriod?

    // 依赖的管理器
    var groupManager: ReminderGroupManager
    var whitelistManager: AppWhitelistManager

    // MARK: - Private Properties
    private var timer: Timer?
    private var scenarioTimer: Timer?
    private var backgroundEntryTime: Date?
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization
    init(groupManager: ReminderGroupManager, whitelistManager: AppWhitelistManager) {
        self.groupManager = groupManager
        self.whitelistManager = whitelistManager

        setupNotificationObservers()
        loadTodayScreenTime()
    }

    // MARK: - Public Methods
    func startTracking() {
        guard !isTracking, groupManager.isTrackingEnabled else { return }

        isTracking = true
        sessionStartTime = Date()

        // 每分钟更新一次
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            self?.updateScreenTime()
        }

        // 如果有复杂情景，启动情景定时器
        if let group = groupManager.activeGroup,
           group.hasComplexScenario,
           group.scenario != nil {
            startScenarioTracking()
        }

        print("开始跟踪屏幕时间")
    }

    func stopTracking() {
        isTracking = false
        timer?.invalidate()
        timer = nil
        scenarioTimer?.invalidate()
        scenarioTimer = nil

        if let startTime = sessionStartTime {
            let sessionDuration = Date().timeIntervalSince(startTime)
            totalScreenTime += sessionDuration
            saveScreenTime()
        }

        sessionStartTime = nil
        print("停止跟踪屏幕时间")
    }

    func pauseTracking() {
        if let startTime = sessionStartTime {
            let sessionDuration = Date().timeIntervalSince(startTime)
            totalScreenTime += sessionDuration
            saveScreenTime()
            sessionStartTime = nil
        }

        timer?.invalidate()
        timer = nil
        scenarioTimer?.invalidate()
        scenarioTimer = nil
    }

    func resumeTracking() {
        sessionStartTime = Date()

        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            self?.updateScreenTime()
        }

        if let group = groupManager.activeGroup,
           group.hasComplexScenario,
           group.scenario != nil {
            startScenarioTracking()
        }
    }

    func resetDailyTime() {
        totalScreenTime = 0
        saveScreenTime()
    }

    // MARK: - 情景管理
    private func startScenarioTracking() {
        guard let group = groupManager.activeGroup,
              let scenario = group.scenario,
              let currentSession = scenario.currentSession else {
            return
        }

        currentScenarioSession = currentSession

        // 设置定时器，当前session结束时触发
        let duration = TimeInterval(currentSession.durationMinutes * 60)
        scenarioTimer?.invalidate()
        scenarioTimer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { [weak self] _ in
            self?.handleSessionComplete()
        }

        // 发送session开始通知
        NotificationCenter.default.post(
            name: NSNotification.Name("ScenarioSessionStarted"),
            object: nil,
            userInfo: ["session": currentSession]
        )
    }

    private func handleSessionComplete() {
        guard let group = groupManager.activeGroup else { return }

        // 发送session完成通知
        NotificationCenter.default.post(
            name: NSNotification.Name("ScenarioSessionCompleted"),
            object: nil,
            userInfo: ["session": currentScenarioSession as Any]
        )

        // 切换到下一个session
        groupManager.nextSession(for: group.id)

        // 如果还有更多session，继续跟踪
        if let updatedGroup = groupManager.groups.first(where: { $0.id == group.id }),
           let scenario = updatedGroup.scenario,
           scenario.hasMoreSessions {
            startScenarioTracking()
        }
    }

    func skipToNextSession() {
        guard let group = groupManager.activeGroup else { return }
        scenarioTimer?.invalidate()
        groupManager.nextSession(for: group.id)
        startScenarioTracking()
    }

    func restartScenario() {
        guard let group = groupManager.activeGroup else { return }
        scenarioTimer?.invalidate()
        groupManager.startScenario(for: group.id)
        startScenarioTracking()
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
        checkAndResetIfNewDay()

        if isTracking && groupManager.isTrackingEnabled {
            sessionStartTime = Date()
        }
    }

    private func updateScreenTime() {
        guard let startTime = sessionStartTime,
              let group = groupManager.activeGroup else { return }

        let currentSessionTime = Date().timeIntervalSince(startTime)
        let currentTotal = totalScreenTime + currentSessionTime

        let limitSeconds = TimeInterval(group.timeLimitMinutes * 60)

        // 检查是否超过限制
        if currentTotal >= limitSeconds {
            triggerReminder(group: group)
        }

        // 定期保存
        if Int(currentTotal) % 300 == 0 { // 每5分钟保存一次
            saveScreenTime()
        }
    }

    private func triggerReminder(group: ReminderGroup) {
        shouldShowAlert = true

        NotificationCenter.default.post(
            name: NSNotification.Name("ScreenTimeLimitReached"),
            object: nil,
            userInfo: [
                "totalTime": currentTotalTime,
                "group": group
            ]
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

    // MARK: - Computed Properties
    var currentTotalTime: TimeInterval {
        var total = totalScreenTime
        if let startTime = sessionStartTime {
            total += Date().timeIntervalSince(startTime)
        }
        return total
    }

    var remainingTime: TimeInterval {
        guard let group = groupManager.activeGroup else { return 0 }
        let limitSeconds = TimeInterval(group.timeLimitMinutes * 60)
        return max(0, limitSeconds - currentTotalTime)
    }

    var isOverLimit: Bool {
        guard let group = groupManager.activeGroup else { return false }
        let limitSeconds = TimeInterval(group.timeLimitMinutes * 60)
        return currentTotalTime >= limitSeconds
    }

    var progress: Double {
        guard let group = groupManager.activeGroup else { return 0 }
        let limitSeconds = TimeInterval(group.timeLimitMinutes * 60)
        return min(1.0, currentTotalTime / limitSeconds)
    }

    // MARK: - 场景相关计算属性
    var scenarioProgress: Double {
        guard let session = currentScenarioSession,
              let scenario = groupManager.activeGroup?.scenario,
              let sessionStartTime = scenario.sessionStartTime else {
            return 0
        }

        let elapsed = Date().timeIntervalSince(sessionStartTime)
        let total = TimeInterval(session.durationMinutes * 60)
        return min(1.0, elapsed / total)
    }

    var scenarioRemainingTime: TimeInterval {
        guard let session = currentScenarioSession,
              let scenario = groupManager.activeGroup?.scenario,
              let sessionStartTime = scenario.sessionStartTime else {
            return 0
        }

        let elapsed = Date().timeIntervalSince(sessionStartTime)
        let total = TimeInterval(session.durationMinutes * 60)
        return max(0, total - elapsed)
    }
}
