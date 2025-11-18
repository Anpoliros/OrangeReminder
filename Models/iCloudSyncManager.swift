//
//  iCloudSyncManager.swift
//  OrangeReminder
//
//  iCloud同步管理器
//

import Foundation
import CloudKit
import Combine

class iCloudSyncManager: ObservableObject {
    @Published var isSyncing: Bool = false
    @Published var lastSyncDate: Date?
    @Published var syncStatus: SyncStatus = .idle

    enum SyncStatus {
        case idle
        case syncing
        case success
        case failed(Error)

        var message: String {
            switch self {
            case .idle:
                return "就绪"
            case .syncing:
                return "同步中..."
            case .success:
                return "同步成功"
            case .failed(let error):
                return "同步失败: \(error.localizedDescription)"
            }
        }
    }

    private let container: CKContainer
    private let database: CKDatabase
    private let backupFileName = "OrangeReminder_Backup.json"

    init() {
        container = CKContainer.default()
        database = container.privateCloudDatabase
        loadLastSyncDate()
    }

    // MARK: - iCloud Document Storage

    /// 导出配置到iCloud Drive
    func exportToiCloud(groupManager: ReminderGroupManager, whitelistManager: AppWhitelistManager) {
        isSyncing = true
        syncStatus = .syncing

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }

            do {
                // 准备数据
                let backup = BackupData(
                    groups: groupManager.groups,
                    activeGroupId: groupManager.activeGroupId,
                    whitelistedApps: whitelistManager.whitelistedApps,
                    backupDate: Date()
                )

                // 编码为JSON
                let encoder = JSONEncoder()
                encoder.outputFormatting = .prettyPrinted
                encoder.dateEncodingStrategy = .iso8601
                let data = try encoder.encode(backup)

                // 保存到iCloud Drive
                if let iCloudURL = FileManager.default.url(forUbiquityContainerIdentifier: nil)?
                    .appendingPathComponent("Documents")
                    .appendingPathComponent(self.backupFileName) {

                    // 确保目录存在
                    let directory = iCloudURL.deletingLastPathComponent()
                    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)

                    // 写入文件
                    try data.write(to: iCloudURL)

                    DispatchQueue.main.async {
                        self.lastSyncDate = Date()
                        self.saveLastSyncDate()
                        self.isSyncing = false
                        self.syncStatus = .success
                        print("✅ 成功导出到iCloud: \(iCloudURL.path)")
                    }
                } else {
                    throw NSError(domain: "iCloudSync", code: -1, userInfo: [
                        NSLocalizedDescriptionKey: "iCloud Drive不可用，请在设置中启用iCloud Drive"
                    ])
                }

            } catch {
                DispatchQueue.main.async {
                    self.isSyncing = false
                    self.syncStatus = .failed(error)
                    print("❌ 导出到iCloud失败: \(error.localizedDescription)")
                }
            }
        }
    }

    /// 从iCloud Drive导入配置
    func importFromiCloud(groupManager: ReminderGroupManager, whitelistManager: AppWhitelistManager, completion: @escaping (Bool, String) -> Void) {
        isSyncing = true
        syncStatus = .syncing

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }

            do {
                // 从iCloud Drive读取
                guard let iCloudURL = FileManager.default.url(forUbiquityContainerIdentifier: nil)?
                    .appendingPathComponent("Documents")
                    .appendingPathComponent(self.backupFileName) else {
                    throw NSError(domain: "iCloudSync", code: -1, userInfo: [
                        NSLocalizedDescriptionKey: "iCloud Drive不可用"
                    ])
                }

                // 检查文件是否存在
                guard FileManager.default.fileExists(atPath: iCloudURL.path) else {
                    throw NSError(domain: "iCloudSync", code: -2, userInfo: [
                        NSLocalizedDescriptionKey: "未找到备份文件"
                    ])
                }

                // 读取数据
                let data = try Data(contentsOf: iCloudURL)

                // 解码
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let backup = try decoder.decode(BackupData.self, from: data)

                // 恢复数据
                DispatchQueue.main.async {
                    groupManager.groups = backup.groups
                    if let activeId = backup.activeGroupId {
                        groupManager.activeGroupId = activeId
                    }
                    whitelistManager.whitelistedApps = backup.whitelistedApps

                    self.lastSyncDate = Date()
                    self.saveLastSyncDate()
                    self.isSyncing = false
                    self.syncStatus = .success

                    let message = "成功从iCloud恢复配置（备份时间: \(self.formatDate(backup.backupDate))）"
                    completion(true, message)
                    print("✅ \(message)")
                }

            } catch {
                DispatchQueue.main.async {
                    self.isSyncing = false
                    self.syncStatus = .failed(error)
                    completion(false, error.localizedDescription)
                    print("❌ 从iCloud导入失败: \(error.localizedDescription)")
                }
            }
        }
    }

    /// 检查iCloud备份文件是否存在
    func checkBackupExists(completion: @escaping (Bool, Date?) -> Void) {
        DispatchQueue.global(qos: .utility).async { [weak self] in
            guard let self = self else { return }

            guard let iCloudURL = FileManager.default.url(forUbiquityContainerIdentifier: nil)?
                .appendingPathComponent("Documents")
                .appendingPathComponent(self.backupFileName) else {
                DispatchQueue.main.async {
                    completion(false, nil)
                }
                return
            }

            let exists = FileManager.default.fileExists(atPath: iCloudURL.path)

            if exists {
                do {
                    let attributes = try FileManager.default.attributesOfItem(atPath: iCloudURL.path)
                    let modificationDate = attributes[.modificationDate] as? Date
                    DispatchQueue.main.async {
                        completion(true, modificationDate)
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(true, nil)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    completion(false, nil)
                }
            }
        }
    }

    /// 删除iCloud备份
    func deleteBackup(completion: @escaping (Bool, String) -> Void) {
        DispatchQueue.global(qos: .utility).async { [weak self] in
            guard let self = self else { return }

            do {
                guard let iCloudURL = FileManager.default.url(forUbiquityContainerIdentifier: nil)?
                    .appendingPathComponent("Documents")
                    .appendingPathComponent(self.backupFileName) else {
                    throw NSError(domain: "iCloudSync", code: -1, userInfo: [
                        NSLocalizedDescriptionKey: "iCloud Drive不可用"
                    ])
                }

                if FileManager.default.fileExists(atPath: iCloudURL.path) {
                    try FileManager.default.removeItem(at: iCloudURL)
                    DispatchQueue.main.async {
                        completion(true, "备份已删除")
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(false, "备份文件不存在")
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    completion(false, error.localizedDescription)
                }
            }
        }
    }

    // MARK: - Helper Methods

    private func saveLastSyncDate() {
        UserDefaults.standard.set(lastSyncDate, forKey: "lastSyncDate")
    }

    private func loadLastSyncDate() {
        lastSyncDate = UserDefaults.standard.object(forKey: "lastSyncDate") as? Date
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: date)
    }
}

// MARK: - Backup Data Model
struct BackupData: Codable {
    let groups: [ReminderGroup]
    let activeGroupId: UUID?
    let whitelistedApps: [AppInfo]
    let backupDate: Date
}
