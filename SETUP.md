# 🚀 OrangeReminder 快速设置指南

## 方式一：使用 Xcode 打开（推荐）

### 1. 打开项目
```bash
cd OrangeReminder
open OrangeReminder.xcodeproj
```

或者直接双击 `OrangeReminder.xcodeproj` 文件

### 2. 配置签名

在 Xcode 中：

1. 选择项目根节点（蓝色图标）
2. 选择 **OrangeReminder** target
3. 进入 **Signing & Capabilities** 标签
4. 设置你的 **Team**（需要 Apple Developer 账号）
5. Bundle Identifier 会自动设置为 `com.orangereminder.app`

6. 对 **OrangeReminderWidget** target 重复步骤 2-5
   - Bundle Identifier: `com.orangereminder.app.widget`

### 3. 配置 Capabilities

确保以下 Capabilities 已启用（应该已经配置好）：

**主应用 (OrangeReminder):**
- ✅ Push Notifications
- ✅ Background Modes
  - ✅ Background processing
- ✅ App Groups
  - ✅ `group.com.orangereminder.shared`
- ✅ iCloud
  - ✅ CloudKit
  - ✅ iCloud Documents

**Widget Extension (OrangeReminderWidget):**
- ✅ App Groups
  - ✅ `group.com.orangereminder.shared`

### 4. 运行项目

1. 选择模拟器或真机
2. 点击运行按钮（⌘R）
3. 等待编译完成

### 5. 添加 Widget

1. 长按主屏幕
2. 点击左上角 "+"
3. 搜索 "OrangeReminder"
4. 选择小号或中号 Widget
5. 添加到主屏幕

## 方式二：命令行构建

### 1. 列出可用设备
```bash
xcodebuild -showdestinations -scheme OrangeReminder
```

### 2. 构建项目
```bash
xcodebuild \
  -project OrangeReminder.xcodeproj \
  -scheme OrangeReminder \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  build
```

### 3. 运行项目
```bash
xcodebuild \
  -project OrangeReminder.xcodeproj \
  -scheme OrangeReminder \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  run
```

## 常见问题

### Q: 签名错误
**A:** 确保在 Xcode 中设置了有效的 Team，并且 Bundle Identifier 唯一。

### Q: App Groups 错误
**A:**
1. 确保在 Apple Developer 中创建了 App Group: `group.com.orangereminder.shared`
2. 确保主应用和 Widget 都添加了这个 App Group

### Q: iCloud 不可用
**A:**
1. 在 Developer 中启用 iCloud 权限
2. 确保在设备/模拟器上登录了 iCloud
3. 系统设置 > iCloud > iCloud Drive 已开启

### Q: Widget 不显示
**A:**
1. 确保 Widget Extension 编译成功
2. 重新安装应用
3. 在主屏幕长按 > 添加 Widget

### Q: 通知权限
**A:** 首次运行时会自动请求通知权限，请点击"允许"

## 项目结构

```
OrangeReminder/
├── OrangeReminder.xcodeproj/    # Xcode 项目文件
│   └── project.pbxproj          # 项目配置
├── OrangeReminderApp.swift      # 应用入口
├── Models/                      # 数据模型层
│   ├── ReminderGroup.swift
│   ├── ReminderGroupManager.swift
│   ├── AppWhitelistManager.swift
│   ├── EnhancedScreenTimeTracker.swift
│   ├── NotificationManager.swift
│   ├── iCloudSyncManager.swift
│   └── ScreenTimeTracker.swift
├── Views/                       # UI 视图层
│   ├── MainTabView.swift
│   ├── CurrentReminderView.swift
│   ├── ReminderGroupsView.swift
│   ├── GroupEditView.swift
│   ├── EnhancedSettingsView.swift
│   ├── WhitelistManagerView.swift
│   ├── InAppAlertView.swift
│   ├── ContentView.swift
│   └── SettingsView.swift
├── Widget/                      # Widget Extension
│   ├── OrangeReminderWidget.swift
│   └── Info.plist
├── Assets.xcassets/            # 资源文件
├── Info.plist                   # 应用配置
├── OrangeReminder.entitlements # 主应用权限
├── WidgetExtension.entitlements # Widget 权限
└── README.md                    # 项目文档
```

## 构建要求

- **Xcode**: 14.0+
- **iOS**: 15.0+
- **Swift**: 5.7+
- **macOS**: 12.0+ (用于开发)

## 下一步

1. ✅ 打开项目
2. ✅ 配置签名
3. ✅ 运行应用
4. ✅ 测试功能
5. ✅ 添加 Widget
6. 🎉 开始使用！

## 获取帮助

- 查看 [README.md](README.md) 了解功能详情
- 提交 [GitHub Issue](https://github.com/Anpoliros/OrangeReminder/issues)
- 查看 [Apple Developer 文档](https://developer.apple.com/documentation/)

---

**祝你使用愉快！** 🍊✨
