//
//  AppWhitelistManager.swift
//  OrangeReminder
//
//  应用白名单管理器
//

import Foundation
import Combine

// MARK: - 应用信息
struct AppInfo: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var name: String
    var bundleIdentifier: String?
    var category: AppCategory
    var icon: String

    enum AppCategory: String, Codable, CaseIterable {
        case productivity = "生产力工具"
        case education = "教育学习"
        case health = "健康健身"
        case music = "音乐音频"
        case reading = "阅读新闻"
        case utilities = "实用工具"
        case social = "社交通讯"
        case entertainment = "娱乐游戏"
        case other = "其他"

        var icon: String {
            switch self {
            case .productivity: return "briefcase.fill"
            case .education: return "book.fill"
            case .health: return "heart.fill"
            case .music: return "music.note"
            case .reading: return "newspaper.fill"
            case .utilities: return "wrench.and.screwdriver.fill"
            case .social: return "message.fill"
            case .entertainment: return "gamecontroller.fill"
            case .other: return "app.fill"
            }
        }

        var color: String {
            switch self {
            case .productivity: return "blue"
            case .education: return "green"
            case .health: return "red"
            case .music: return "purple"
            case .reading: return "orange"
            case .utilities: return "gray"
            case .social: return "cyan"
            case .entertainment: return "pink"
            case .other: return "brown"
            }
        }
    }
}

class AppWhitelistManager: ObservableObject {
    @Published var whitelistedApps: [AppInfo] = []

    private let whitelistKey = "appWhitelist"

    init() {
        loadWhitelist()

        // 添加一些预设应用
        if whitelistedApps.isEmpty {
            addPresetApps()
        }
    }

    // MARK: - CRUD Operations

    func addApp(_ app: AppInfo) {
        var newApp = app
        newApp.id = UUID()
        whitelistedApps.append(newApp)
        saveWhitelist()
    }

    func updateApp(_ app: AppInfo) {
        if let index = whitelistedApps.firstIndex(where: { $0.id == app.id }) {
            whitelistedApps[index] = app
            saveWhitelist()
        }
    }

    func deleteApp(at offsets: IndexSet) {
        whitelistedApps.remove(atOffsets: offsets)
        saveWhitelist()
    }

    func deleteApp(_ app: AppInfo) {
        if let index = whitelistedApps.firstIndex(where: { $0.id == app.id }) {
            whitelistedApps.remove(at: index)
            saveWhitelist()
        }
    }

    func isAppWhitelisted(_ appName: String) -> Bool {
        return whitelistedApps.contains(where: { $0.name.lowercased() == appName.lowercased() })
    }

    func isAppWhitelisted(bundleId: String) -> Bool {
        return whitelistedApps.contains(where: { $0.bundleIdentifier == bundleId })
    }

    // MARK: - Persistence

    private func saveWhitelist() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(whitelistedApps)
            UserDefaults.standard.set(data, forKey: whitelistKey)
        } catch {
            print("保存白名单失败: \(error.localizedDescription)")
        }
    }

    private func loadWhitelist() {
        guard let data = UserDefaults.standard.data(forKey: whitelistKey) else {
            return
        }

        do {
            let decoder = JSONDecoder()
            whitelistedApps = try decoder.decode([AppInfo].self, from: data)
        } catch {
            print("加载白名单失败: \(error.localizedDescription)")
        }
    }

    // MARK: - Preset Apps

    private func addPresetApps() {
        let presetApps = [
            AppInfo(name: "提醒事项", bundleIdentifier: "com.apple.reminders", category: .productivity, icon: "list.bullet"),
            AppInfo(name: "日历", bundleIdentifier: "com.apple.mobilecal", category: .productivity, icon: "calendar"),
            AppInfo(name: "备忘录", bundleIdentifier: "com.apple.mobilenotes", category: .productivity, icon: "note.text"),
            AppInfo(name: "图书", bundleIdentifier: "com.apple.iBooks", category: .reading, icon: "book"),
            AppInfo(name: "播客", bundleIdentifier: "com.apple.podcasts", category: .education, icon: "mic"),
            AppInfo(name: "健康", bundleIdentifier: "com.apple.Health", category: .health, icon: "heart.fill"),
            AppInfo(name: "音乐", bundleIdentifier: "com.apple.Music", category: .music, icon: "music.note"),
        ]

        whitelistedApps = presetApps
        saveWhitelist()
    }

    // MARK: - 按类别获取

    func apps(in category: AppInfo.AppCategory) -> [AppInfo] {
        return whitelistedApps.filter { $0.category == category }
    }

    func groupedApps() -> [AppInfo.AppCategory: [AppInfo]] {
        Dictionary(grouping: whitelistedApps, by: { $0.category })
    }
}
