//
//  WhitelistManagerView.swift
//  OrangeReminder
//
//  应用白名单管理视图
//

import SwiftUI

struct WhitelistManagerView: View {
    @EnvironmentObject var whitelistManager: AppWhitelistManager
    @Environment(\.dismiss) var dismiss

    @State private var showAddApp = false
    @State private var selectedCategory: AppInfo.AppCategory?

    var body: some View {
        NavigationView {
            List {
                // MARK: - 说明
                Section {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(.blue)
                            Text("什么是白名单？")
                                .fontWeight(.semibold)
                        }

                        Text("白名单中的应用使用时间不会被计入统计。适合添加生产力工具、学习应用等。")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 5)
                }

                // MARK: - 按类别分组显示
                ForEach(AppInfo.AppCategory.allCases, id: \.self) { category in
                    let apps = whitelistManager.apps(in: category)
                    if !apps.isEmpty {
                        Section {
                            ForEach(apps) { app in
                                AppRow(app: app)
                            }
                            .onDelete { offsets in
                                deleteApps(in: category, at: offsets)
                            }
                        } header: {
                            HStack {
                                Image(systemName: category.icon)
                                Text(category.rawValue)
                            }
                        }
                    }
                }

                // MARK: - 快捷添加预设应用
                Section {
                    Button(action: { showAddApp = true }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.orange)
                            Text("添加应用")
                                .foregroundColor(.orange)
                        }
                    }
                } header: {
                    Text("管理")
                }
            }
            .navigationTitle("应用白名单")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("完成") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
            .sheet(isPresented: $showAddApp) {
                AddAppView()
            }
        }
    }

    private func deleteApps(in category: AppInfo.AppCategory, at offsets: IndexSet) {
        let apps = whitelistManager.apps(in: category)
        for index in offsets {
            whitelistManager.deleteApp(apps[index])
        }
    }
}

// MARK: - App Row
struct AppRow: View {
    let app: AppInfo

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: app.icon)
                .font(.title3)
                .foregroundColor(Color(app.category.color))
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(Color(app.category.color).opacity(0.2))
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(app.name)
                    .font(.headline)

                if let bundleId = app.bundleIdentifier {
                    Text(bundleId)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
                .font(.title3)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Add App View
struct AddAppView: View {
    @EnvironmentObject var whitelistManager: AppWhitelistManager
    @Environment(\.dismiss) var dismiss

    @State private var appName = ""
    @State private var bundleIdentifier = ""
    @State private var selectedCategory: AppInfo.AppCategory = .productivity
    @State private var selectedIcon = "app.fill"

    let icons = ["app.fill", "books.vertical.fill", "book.fill", "newspaper.fill",
                 "music.note", "headphones", "gamecontroller.fill", "heart.fill",
                 "figure.run", "leaf.fill", "paintbrush.fill", "camera.fill"]

    var body: some View {
        NavigationView {
            Form {
                Section("应用信息") {
                    TextField("应用名称", text: $appName)

                    TextField("Bundle ID (可选)", text: $bundleIdentifier)
                        .autocapitalization(.none)
                        .font(.caption)
                }

                Section("分类") {
                    Picker("应用分类", selection: $selectedCategory) {
                        ForEach(AppInfo.AppCategory.allCases, id: \.self) { category in
                            Label(category.rawValue, systemImage: category.icon)
                                .tag(category)
                        }
                    }
                }

                Section("图标") {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))], spacing: 15) {
                        ForEach(icons, id: \.self) { icon in
                            Button(action: {
                                selectedIcon = icon
                            }) {
                                Image(systemName: icon)
                                    .font(.title2)
                                    .foregroundColor(selectedIcon == icon ? .white : Color(selectedCategory.color))
                                    .frame(width: 60, height: 60)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(selectedIcon == icon ?
                                                  Color(selectedCategory.color) :
                                                    Color(selectedCategory.color).opacity(0.2))
                                    )
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }

                Section {
                    Text("提示: Bundle ID用于精确识别应用，可在App Store或应用信息中找到。")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("添加应用")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("添加") {
                        addApp()
                        dismiss()
                    }
                    .disabled(appName.isEmpty)
                }
            }
        }
    }

    private func addApp() {
        let app = AppInfo(
            name: appName,
            bundleIdentifier: bundleIdentifier.isEmpty ? nil : bundleIdentifier,
            category: selectedCategory,
            icon: selectedIcon
        )
        whitelistManager.addApp(app)
    }
}

#Preview {
    WhitelistManagerView()
        .environmentObject(AppWhitelistManager())
}
