//
//  ReminderGroupsView.swift
//  OrangeReminder
//
//  提醒组管理视图
//

import SwiftUI

struct ReminderGroupsView: View {
    @EnvironmentObject var groupManager: ReminderGroupManager
    @State private var showAddGroup = false
    @State private var groupToEdit: ReminderGroup?

    var body: some View {
        NavigationView {
            List {
                // MARK: - 模板区域
                Section {
                    ForEach(ReminderGroup.templates) { template in
                        TemplateRow(template: template) {
                            groupManager.addGroup(template)
                        }
                    }
                } header: {
                    Text("快速创建")
                } footer: {
                    Text("从预设模板快速创建提醒组")
                }

                // MARK: - 我的提醒组
                Section {
                    if groupManager.groups.isEmpty {
                        Text("还没有提醒组")
                            .foregroundColor(.secondary)
                            .font(.subheadline)
                    } else {
                        ForEach(groupManager.groups) { group in
                            GroupRow(group: group)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    groupToEdit = group
                                }
                        }
                        .onDelete(perform: groupManager.deleteGroup)
                    }
                } header: {
                    Text("我的提醒组")
                }
            }
            .navigationTitle("提醒组")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAddGroup = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                    }
                }
            }
            .sheet(isPresented: $showAddGroup) {
                GroupEditView(group: nil, isNew: true)
            }
            .sheet(item: $groupToEdit) { group in
                GroupEditView(group: group, isNew: false)
            }
        }
    }
}

// MARK: - Template Row
struct TemplateRow: View {
    let template: ReminderGroup
    let onAdd: () -> Void

    var body: some View {
        HStack {
            Image(systemName: template.icon)
                .font(.title2)
                .foregroundColor(Color(template.color))
                .frame(width: 50, height: 50)
                .background(
                    Circle()
                        .fill(Color(template.color).opacity(0.2))
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(template.name)
                    .font(.headline)

                Text("\(template.timeLimitMinutes) 分钟")
                    .font(.caption)
                    .foregroundColor(.secondary)

                if template.hasComplexScenario {
                    Label("含情景模式", systemImage: "figure.run")
                        .font(.caption2)
                        .foregroundColor(.blue)
                }
            }

            Spacer()

            Button(action: onAdd) {
                Text("添加")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(Color.orange)
                    .cornerRadius(20)
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Group Row
struct GroupRow: View {
    @EnvironmentObject var groupManager: ReminderGroupManager
    let group: ReminderGroup

    var body: some View {
        HStack(spacing: 15) {
            // 图标
            Image(systemName: group.icon)
                .font(.title2)
                .foregroundColor(Color(group.color))
                .frame(width: 50, height: 50)
                .background(
                    Circle()
                        .fill(Color(group.color).opacity(0.2))
                )

            // 信息
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(group.name)
                        .font(.headline)

                    if groupManager.activeGroupId == group.id {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.caption)
                    }
                }

                HStack(spacing: 12) {
                    Label("\(group.timeLimitMinutes)分钟", systemImage: "clock")
                    Label(group.notificationStyle.rawValue, systemImage: "bell")
                }
                .font(.caption)
                .foregroundColor(.secondary)

                if group.hasComplexScenario, let scenario = group.scenario {
                    Label("\(scenario.sessions.count)个阶段", systemImage: "figure.run")
                        .font(.caption2)
                        .foregroundColor(.blue)
                }

                if !group.whitelistedApps.isEmpty {
                    Label("\(group.whitelistedApps.count)个白名单应用", systemImage: "checkmark.shield")
                        .font(.caption2)
                        .foregroundColor(.green)
                }
            }

            Spacer()

            // 操作按钮
            Menu {
                Button(action: {
                    groupManager.activateGroup(group)
                }) {
                    Label("设为当前", systemImage: "checkmark.circle")
                }

                Button(action: {
                    groupManager.duplicateGroup(group)
                }) {
                    Label("复制", systemImage: "doc.on.doc")
                }

                Divider()

                Button(role: .destructive, action: {
                    groupManager.deleteGroup(group)
                }) {
                    Label("删除", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.title3)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    let groupManager = ReminderGroupManager()
    return ReminderGroupsView()
        .environmentObject(groupManager)
}
