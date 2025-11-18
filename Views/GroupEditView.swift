//
//  GroupEditView.swift
//  OrangeReminder
//
//  提醒组编辑视图
//

import SwiftUI

struct GroupEditView: View {
    @EnvironmentObject var groupManager: ReminderGroupManager
    @Environment(\.dismiss) var dismiss

    let isNew: Bool

    @State private var name: String
    @State private var icon: String
    @State private var color: String
    @State private var timeLimitMinutes: Int
    @State private var notificationStyle: ReminderGroup.NotificationStyle
    @State private var hasComplexScenario: Bool
    @State private var scenario: UsageScenario?

    init(group: ReminderGroup?, isNew: Bool) {
        self.isNew = isNew
        if let group = group {
            _name = State(initialValue: group.name)
            _icon = State(initialValue: group.icon)
            _color = State(initialValue: group.color)
            _timeLimitMinutes = State(initialValue: group.timeLimitMinutes)
            _notificationStyle = State(initialValue: group.notificationStyle)
            _hasComplexScenario = State(initialValue: group.hasComplexScenario)
            _scenario = State(initialValue: group.scenario)
        } else {
            _name = State(initialValue: "新提醒组")
            _icon = State(initialValue: "bell.fill")
            _color = State(initialValue: "orange")
            _timeLimitMinutes = State(initialValue: 60)
            _notificationStyle = State(initialValue: .timeSensitive)
            _hasComplexScenario = State(initialValue: false)
            _scenario = State(initialValue: nil)
        }
    }

    var body: some View {
        NavigationView {
            Form {
                // MARK: - 基本信息
                Section("基本信息") {
                    TextField("名称", text: $name)

                    HStack {
                        Text("图标")
                        Spacer()
                        IconPicker(selectedIcon: $icon, color: $color)
                    }

                    ColorPicker("颜色", selection: Binding(
                        get: { Color(color) },
                        set: { newColor in
                            // 将Color转换为颜色名称
                            color = colorName(from: newColor)
                        }
                    ))
                }

                // MARK: - 时间设置
                Section {
                    Stepper(value: $timeLimitMinutes, in: 5...480, step: 5) {
                        HStack {
                            Text("使用限制")
                            Spacer()
                            Text("\(timeLimitMinutes) 分钟")
                                .foregroundColor(.secondary)
                        }
                    }
                } header: {
                    Text("时间设置")
                } footer: {
                    Text("每日最多使用 \(formatMinutes(timeLimitMinutes))")
                }

                // MARK: - 提醒方式
                Section("提醒方式") {
                    Picker("提醒方式", selection: $notificationStyle) {
                        ForEach(ReminderGroup.NotificationStyle.allCases, id: \.self) { style in
                            Text(style.rawValue).tag(style)
                        }
                    }
                    .pickerStyle(.menu)
                }

                // MARK: - 复杂情景
                Section {
                    Toggle("启用情景模式", isOn: $hasComplexScenario)

                    if hasComplexScenario {
                        NavigationLink("配置情景") {
                            ScenarioEditView(scenario: $scenario)
                        }

                        if let scenario = scenario {
                            Text("\(scenario.sessions.count) 个阶段")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        } else {
                            Text("未配置")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                    }
                } header: {
                    Text("情景模式")
                } footer: {
                    Text("类似番茄钟的工作-休息循环模式")
                }
            }
            .navigationTitle(isNew ? "新建提醒组" : "编辑提醒组")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        saveGroup()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(name.isEmpty)
                }
            }
        }
    }

    // MARK: - Helper Methods
    private func saveGroup() {
        if isNew {
            let newGroup = ReminderGroup(
                name: name,
                icon: icon,
                color: color,
                timeLimitMinutes: timeLimitMinutes,
                notificationStyle: notificationStyle,
                hasComplexScenario: hasComplexScenario,
                scenario: scenario
            )
            groupManager.addGroup(newGroup)
        } else {
            // 更新现有组
            if let existingGroup = groupManager.groups.first(where: { $0.name == name || $0.id.uuidString == name }) {
                var updatedGroup = existingGroup
                updatedGroup.name = name
                updatedGroup.icon = icon
                updatedGroup.color = color
                updatedGroup.timeLimitMinutes = timeLimitMinutes
                updatedGroup.notificationStyle = notificationStyle
                updatedGroup.hasComplexScenario = hasComplexScenario
                updatedGroup.scenario = scenario
                groupManager.updateGroup(updatedGroup)
            }
        }
    }

    private func formatMinutes(_ minutes: Int) -> String {
        let hours = minutes / 60
        let mins = minutes % 60
        if hours > 0 {
            return "\(hours) 小时 \(mins) 分钟"
        } else {
            return "\(mins) 分钟"
        }
    }

    private func colorName(from color: Color) -> String {
        // 简化版本，实际应该有更完善的颜色映射
        return "orange"
    }
}

// MARK: - Icon Picker
struct IconPicker: View {
    @Binding var selectedIcon: String
    @Binding var color: String

    let icons = ["bell.fill", "clock.fill", "book.fill", "briefcase.fill", "moon.fill",
                 "sun.max.fill", "heart.fill", "star.fill", "flag.fill", "target"]

    var body: some View {
        Menu {
            ForEach(icons, id: \.self) { icon in
                Button(action: {
                    selectedIcon = icon
                }) {
                    Label("", systemImage: icon)
                }
            }
        } label: {
            Image(systemName: selectedIcon)
                .font(.title2)
                .foregroundColor(Color(color))
        }
    }
}

// MARK: - Scenario Edit View
struct ScenarioEditView: View {
    @Binding var scenario: UsageScenario?
    @Environment(\.dismiss) var dismiss

    @State private var sessions: [SessionPeriod] = []
    @State private var repeatCycle: Bool = true

    var body: some View {
        Form {
            Section {
                Toggle("循环重复", isOn: $repeatCycle)
            } footer: {
                Text("启用后，完成所有阶段后将自动重新开始")
            }

            Section("阶段设置") {
                ForEach(sessions.indices, id: \.self) { index in
                    SessionRow(session: $sessions[index])
                }
                .onDelete(perform: deleteSessions)
                .onMove(perform: moveSessions)

                Button(action: addSession) {
                    Label("添加阶段", systemImage: "plus.circle.fill")
                }
            }
        }
        .navigationTitle("配置情景")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("保存") {
                    saveScenario()
                    dismiss()
                }
                .disabled(sessions.isEmpty)
            }

            ToolbarItem(placement: .navigationBarLeading) {
                EditButton()
            }
        }
        .onAppear {
            if let scenario = scenario {
                sessions = scenario.sessions
                repeatCycle = scenario.repeatCycle
            } else {
                // 默认番茄钟设置
                sessions = [
                    SessionPeriod(durationMinutes: 25, type: .work, name: "专注工作"),
                    SessionPeriod(durationMinutes: 5, type: .shortBreak, name: "短休息")
                ]
            }
        }
    }

    private func addSession() {
        sessions.append(SessionPeriod(durationMinutes: 25, type: .work, name: "新阶段"))
    }

    private func deleteSessions(at offsets: IndexSet) {
        sessions.remove(atOffsets: offsets)
    }

    private func moveSessions(from source: IndexSet, to destination: Int) {
        sessions.move(fromOffsets: source, toOffset: destination)
    }

    private func saveScenario() {
        scenario = UsageScenario(
            sessions: sessions,
            repeatCycle: repeatCycle
        )
    }
}

// MARK: - Session Row
struct SessionRow: View {
    @Binding var session: SessionPeriod

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            TextField("阶段名称", text: $session.name)

            HStack {
                Picker("类型", selection: $session.type) {
                    ForEach([SessionPeriod.SessionType.work, .shortBreak, .longBreak], id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(.segmented)
            }

            Stepper(value: $session.durationMinutes, in: 1...120) {
                Text("\(session.durationMinutes) 分钟")
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    GroupEditView(group: nil, isNew: true)
        .environmentObject(ReminderGroupManager())
}
