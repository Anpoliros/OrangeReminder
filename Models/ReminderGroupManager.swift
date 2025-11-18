//
//  ReminderGroupManager.swift
//  OrangeReminder
//
//  提醒组管理器
//

import Foundation
import Combine
import SwiftUI

class ReminderGroupManager: ObservableObject {
    // MARK: - Published Properties
    @Published var groups: [ReminderGroup] = []
    @Published var activeGroupId: UUID?
    @Published var isTrackingEnabled: Bool = true

    // MARK: - Computed Properties
    var activeGroup: ReminderGroup? {
        get {
            guard let id = activeGroupId else { return nil }
            return groups.first(where: { $0.id == id })
        }
        set {
            if let group = newValue {
                activeGroupId = group.id
                saveGroups()
            }
        }
    }

    // MARK: - Private Properties
    private let groupsKey = "reminderGroups"
    private let activeGroupKey = "activeGroupId"
    private let trackingEnabledKey = "isTrackingEnabled"

    // MARK: - Initialization
    init() {
        loadGroups()
        loadSettings()

        // 如果没有组，创建默认组
        if groups.isEmpty {
            groups = [ReminderGroup.templates[0]]
            activeGroupId = groups[0].id
            saveGroups()
        }
    }

    // MARK: - CRUD Operations

    func addGroup(_ group: ReminderGroup) {
        var newGroup = group
        newGroup.id = UUID()
        newGroup.createdAt = Date()
        groups.append(newGroup)
        saveGroups()
    }

    func updateGroup(_ group: ReminderGroup) {
        if let index = groups.firstIndex(where: { $0.id == group.id }) {
            groups[index] = group
            saveGroups()
        }
    }

    func deleteGroup(at offsets: IndexSet) {
        let deletedIds = offsets.map { groups[$0].id }
        groups.remove(atOffsets: offsets)

        // 如果删除了当前激活的组，切换到第一个组
        if let activeId = activeGroupId, deletedIds.contains(activeId) {
            activeGroupId = groups.first?.id
        }

        saveGroups()
    }

    func deleteGroup(_ group: ReminderGroup) {
        if let index = groups.firstIndex(where: { $0.id == group.id }) {
            groups.remove(at: index)

            if activeGroupId == group.id {
                activeGroupId = groups.first?.id
            }

            saveGroups()
        }
    }

    func toggleGroup(_ group: ReminderGroup) {
        if let index = groups.firstIndex(where: { $0.id == group.id }) {
            groups[index].isEnabled.toggle()
            saveGroups()
        }
    }

    func duplicateGroup(_ group: ReminderGroup) {
        var newGroup = group
        newGroup.id = UUID()
        newGroup.name = "\(group.name) 副本"
        newGroup.createdAt = Date()
        groups.append(newGroup)
        saveGroups()
    }

    // MARK: - 快捷操作

    func toggleTracking() {
        isTrackingEnabled.toggle()
        UserDefaults.standard.set(isTrackingEnabled, forKey: trackingEnabledKey)
    }

    func activateGroup(_ group: ReminderGroup) {
        activeGroupId = group.id

        // 更新最后使用时间
        if let index = groups.firstIndex(where: { $0.id == group.id }) {
            groups[index].lastUsedAt = Date()
        }

        UserDefaults.standard.set(activeGroupId?.uuidString, forKey: activeGroupKey)
        saveGroups()
    }

    // MARK: - 情景管理

    func startScenario(for groupId: UUID) {
        guard let index = groups.firstIndex(where: { $0.id == groupId }),
              groups[index].hasComplexScenario,
              var scenario = groups[index].scenario else {
            return
        }

        scenario.reset()
        scenario.sessionStartTime = Date()
        groups[index].scenario = scenario
        saveGroups()
    }

    func nextSession(for groupId: UUID) {
        guard let index = groups.firstIndex(where: { $0.id == groupId }),
              var scenario = groups[index].scenario else {
            return
        }

        scenario.nextSession()
        groups[index].scenario = scenario
        saveGroups()
    }

    // MARK: - Persistence

    private func saveGroups() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(groups)
            UserDefaults.standard.set(data, forKey: groupsKey)
        } catch {
            print("保存提醒组失败: \(error.localizedDescription)")
        }
    }

    private func loadGroups() {
        guard let data = UserDefaults.standard.data(forKey: groupsKey) else {
            return
        }

        do {
            let decoder = JSONDecoder()
            groups = try decoder.decode([ReminderGroup].self, from: data)
        } catch {
            print("加载提醒组失败: \(error.localizedDescription)")
        }
    }

    private func loadSettings() {
        if let idString = UserDefaults.standard.string(forKey: activeGroupKey),
           let id = UUID(uuidString: idString) {
            activeGroupId = id
        }

        isTrackingEnabled = UserDefaults.standard.bool(forKey: trackingEnabledKey)

        // 默认启用跟踪
        if UserDefaults.standard.object(forKey: trackingEnabledKey) == nil {
            isTrackingEnabled = true
        }
    }

    // MARK: - iCloud Sync

    func exportToiCloud() -> Data? {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            return try encoder.encode(groups)
        } catch {
            print("导出到iCloud失败: \(error.localizedDescription)")
            return nil
        }
    }

    func importFromiCloud(data: Data) -> Bool {
        do {
            let decoder = JSONDecoder()
            let importedGroups = try decoder.decode([ReminderGroup].self, from: data)

            // 合并导入的组
            for group in importedGroups {
                if !groups.contains(where: { $0.id == group.id }) {
                    groups.append(group)
                }
            }

            saveGroups()
            return true
        } catch {
            print("从iCloud导入失败: \(error.localizedDescription)")
            return false
        }
    }

    func resetToDefaults() {
        groups = ReminderGroup.templates
        activeGroupId = groups.first?.id
        isTrackingEnabled = true
        saveGroups()
    }
}
