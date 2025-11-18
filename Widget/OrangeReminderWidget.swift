//
//  OrangeReminderWidget.swift
//  OrangeReminder Widget
//
//  Widget小组件 - 快捷切换开关
//

import WidgetKit
import SwiftUI

// MARK: - Widget Entry
struct WidgetEntry: TimelineEntry {
    let date: Date
    let isTrackingEnabled: Bool
    let activeGroupName: String?
    let activeGroupIcon: String?
}

// MARK: - Widget Timeline Provider
struct WidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> WidgetEntry {
        WidgetEntry(
            date: Date(),
            isTrackingEnabled: true,
            activeGroupName: "标准模式",
            activeGroupIcon: "clock.fill"
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (WidgetEntry) -> Void) {
        let entry = createEntry()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WidgetEntry>) -> Void) {
        let entry = createEntry()

        // 每5分钟更新一次
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 5, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))

        completion(timeline)
    }

    private func createEntry() -> WidgetEntry {
        // 从App Group读取数据
        let sharedDefaults = UserDefaults(suiteName: "group.com.orangereminder.shared")
        let isEnabled = sharedDefaults?.bool(forKey: "isTrackingEnabled") ?? true
        let groupName = sharedDefaults?.string(forKey: "activeGroupName")
        let groupIcon = sharedDefaults?.string(forKey: "activeGroupIcon")

        return WidgetEntry(
            date: Date(),
            isTrackingEnabled: isEnabled,
            activeGroupName: groupName,
            activeGroupIcon: groupIcon
        )
    }
}

// MARK: - Widget View
struct WidgetEntryView: View {
    var entry: WidgetEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

// MARK: - Small Widget
struct SmallWidgetView: View {
    let entry: WidgetEntry

    var body: some View {
        ZStack {
            // 背景渐变
            LinearGradient(
                colors: entry.isTrackingEnabled ?
                    [Color.orange, Color.red] :
                    [Color.gray, Color.gray.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(spacing: 12) {
                // 图标
                Image(systemName: entry.isTrackingEnabled ? "play.circle.fill" : "pause.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.white)

                // 状态文本
                Text(entry.isTrackingEnabled ? "追踪中" : "已暂停")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                // 提醒组名称
                if let groupName = entry.activeGroupName {
                    Text(groupName)
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.9))
                        .lineLimit(1)
                }

                // 点击提示
                Text("轻点切换")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding()
        }
        .widgetURL(URL(string: "orangereminder://toggle")!)
    }
}

// MARK: - Medium Widget
struct MediumWidgetView: View {
    let entry: WidgetEntry

    var body: some View {
        ZStack {
            LinearGradient(
                colors: entry.isTrackingEnabled ?
                    [Color.orange.opacity(0.3), Color.red.opacity(0.3)] :
                    [Color.gray.opacity(0.2), Color.gray.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            HStack(spacing: 20) {
                // 左侧图标
                ZStack {
                    Circle()
                        .fill(entry.isTrackingEnabled ? Color.orange : Color.gray)
                        .frame(width: 80, height: 80)

                    Image(systemName: entry.isTrackingEnabled ? "play.circle.fill" : "pause.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                }

                // 右侧信息
                VStack(alignment: .leading, spacing: 8) {
                    Text(entry.isTrackingEnabled ? "追踪已开启" : "追踪已暂停")
                        .font(.title3)
                        .fontWeight(.bold)

                    if let groupName = entry.activeGroupName {
                        HStack(spacing: 6) {
                            if let icon = entry.activeGroupIcon {
                                Image(systemName: icon)
                            }
                            Text(groupName)
                        }
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    }

                    Spacer()

                    HStack {
                        Image(systemName: "hand.tap.fill")
                            .font(.caption)
                        Text("轻点切换状态")
                            .font(.caption)
                    }
                    .foregroundColor(.secondary)
                }

                Spacer()
            }
            .padding()
        }
        .widgetURL(URL(string: "orangereminder://toggle")!)
    }
}

// MARK: - Widget Configuration
@main
struct OrangeReminderWidget: Widget {
    let kind: String = "OrangeReminderWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WidgetProvider()) { entry in
            WidgetEntryView(entry: entry)
        }
        .configurationDisplayName("OrangeReminder")
        .description("快速切换追踪状态")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Previews
struct OrangeReminderWidget_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            WidgetEntryView(entry: WidgetEntry(
                date: Date(),
                isTrackingEnabled: true,
                activeGroupName: "工作模式",
                activeGroupIcon: "briefcase.fill"
            ))
            .previewContext(WidgetPreviewContext(family: .systemSmall))

            WidgetEntryView(entry: WidgetEntry(
                date: Date(),
                isTrackingEnabled: false,
                activeGroupName: "工作模式",
                activeGroupIcon: "briefcase.fill"
            ))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
        }
    }
}
