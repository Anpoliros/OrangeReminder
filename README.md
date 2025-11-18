# 🍊 OrangeReminder 2.0 - 专业级健康用机提醒应用

一款功能全面的iOS健康用机应用，通过智能提醒组、情景模式、应用白名单等高级功能，帮助用户建立科学的手机使用习惯。

[![Version](https://img.shields.io/badge/version-2.0.0-orange)](https://github.com/Anpoliros/OrangeReminder)
[![Platform](https://img.shields.io/badge/platform-iOS%2015%2B-blue)](https://developer.apple.com/ios/)
[![Swift](https://img.shields.io/badge/Swift-5.7-orange)](https://swift.org)

## ✨ 2.0 版本新特性

### 🎯 提醒组系统
- **自定义提醒组**：创建多个不同场景的提醒配置
- **快速模板**：内置工作、学习、睡前等5种预设模板
- **一键切换**：快速在不同提醒组之间切换
- **独立配置**：每个提醒组拥有独立的时间限制、提醒方式、白名单

### ⏱️ 情景模式（番茄钟）
- **工作-休息循环**：自定义工作和休息时间段
- **多阶段支持**：支持复杂的时间安排（如 40分钟-5分钟-20分钟-15分钟）
- **循环重复**：自动循环执行时间表
- **实时进度**：可视化显示当前阶段进度
- **灵活控制**：支持跳过、重新开始等操作

### 🛡️ 应用白名单
- **排除统计**：白名单应用不计入使用时间
- **分类管理**：按生产力、教育、健康等8大类别管理
- **自定义添加**：支持手动添加任意应用
- **预设应用**：包含常用生产力和学习工具

### 📱 Widget 小组件
- **桌面快捷开关**：无需打开应用即可切换追踪状态
- **实时状态显示**：显示当前提醒组和追踪状态
- **两种尺寸**：支持小号和中号widget
- **精美设计**：渐变背景，动态颜色

### ☁️ iCloud 同步
- **一键备份**：将所有设置备份到iCloud Drive
- **跨设备恢复**：在新设备上快速恢复配置
- **数据安全**：使用Apple原生iCloud存储
- **同步状态**：实时显示同步状态和时间

## 📱 核心功能

### 1. 智能屏幕时间跟踪
- ⏱️ 实时监控应用使用时间
- 📊 自动统计每日屏幕使用时长
- 🌅 每日自动重置统计数据
- 💾 数据持久化存储
- 🔄 支持暂停/恢复追踪

### 2. 多种提醒方式

#### 📢 标准通知
- 基础的推送通知方式
- 可被系统静音模式影响
- 适合自律性较强的用户

#### ⚡ 时间关键通知（推荐）
- **突破专注模式**的特殊通知
- 使用系统关键警报声音
- 即使在勿扰模式下也能收到提醒
- iOS 15+ 支持

#### 🚨 应用内强制弹窗
- **全屏显示**，无法轻易忽略
- 10秒强制阅读倒计时
- 显示健康建议和休息提示
- 配合后台通知双重保障

#### 🔔 持续声音提醒
- 每分钟重复发送通知
- 持续5次提醒
- 系统振动配合
- 确保用户不会错过

#### 💪 组合提醒（最强效果）
- **同时使用多种提醒方式**
- 时间关键通知 + 应用内弹窗 + 持续声音
- 适合需要强制执行的场景
- 真正无法忽略的提醒

### 3. 预设提醒组模板

#### 📘 标准模式
- 60分钟限制
- 时间关键通知
- 适合日常使用

#### 💼 工作模式
- 120分钟限制
- 应用内强制弹窗
- 40分钟工作 - 5分钟休息 - 40分钟工作 - 15分钟长休息
- 白名单：生产力工具、办公软件

#### 📚 学习模式
- 90分钟限制
- 组合提醒
- 25分钟学习 - 5分钟休息（番茄钟）
- 白名单：学习应用、阅读工具

#### 🌙 睡前模式
- 30分钟限制
- 组合提醒
- 白名单：冥想应用、睡眠音乐

#### 🆓 自由模式
- 180分钟限制
- 标准通知
- 适合周末放松时段

## 🎨 界面设计

### TabView 结构
```
┌─────────────────────────────┐
│  📱 当前提醒 | 📦 提醒组 | ⚙️ 设置  │
└─────────────────────────────┘
```

### Tab 1: 当前提醒
- 🔘 快捷追踪开关
- 🎯 当前提醒组卡片
- ⏱️ 使用时间大显示
- 📊 可视化进度条
- 🏃 情景模式进度（如有）
- 📈 统计卡片
- ⚡ 快捷操作按钮

### Tab 2: 提醒组
- 📋 预设模板列表
- ✏️ 我的提醒组
- ➕ 创建自定义提醒组
- 🔧 编辑/复制/删除
- ✅ 快速激活

### Tab 3: 设置
- 🔄 快捷追踪开关
- 🛡️ 应用白名单管理
- ☁️ iCloud 备份/恢复
- 🔔 通知测试
- 🗑️ 数据管理
- ℹ️ 关于信息

## 🔧 技术架构

### 技术栈
- **框架**: SwiftUI + Combine
- **架构**: MVVM
- **存储**: UserDefaults + iCloud Drive
- **通知**: UNUserNotificationCenter
- **Widget**: WidgetKit
- **同步**: App Groups + CloudKit

### 核心组件

```swift
// 数据模型
ReminderGroup          // 提醒组
UsageScenario          // 使用情景
SessionPeriod          // 时间段
AppInfo                // 应用信息

// 管理器
ReminderGroupManager    // 提醒组管理
AppWhitelistManager     // 白名单管理
EnhancedScreenTimeTracker // 增强的时间跟踪
NotificationManager     // 通知管理
iCloudSyncManager       // iCloud同步

// 视图
MainTabView             // 主TabView
CurrentReminderView     // 当前提醒Tab
ReminderGroupsView      // 提醒组Tab
EnhancedSettingsView    // 设置Tab
GroupEditView           // 提醒组编辑
WhitelistManagerView    // 白名单管理
```

### 项目结构

```
OrangeReminder/
├── OrangeReminderApp.swift     # 应用入口
├── Models/                      # 数据模型
│   ├── ReminderGroup.swift
│   ├── ReminderGroupManager.swift
│   ├── AppWhitelistManager.swift
│   ├── EnhancedScreenTimeTracker.swift
│   ├── NotificationManager.swift
│   └── iCloudSyncManager.swift
├── Views/                       # 视图
│   ├── MainTabView.swift
│   ├── CurrentReminderView.swift
│   ├── ReminderGroupsView.swift
│   ├── GroupEditView.swift
│   ├── EnhancedSettingsView.swift
│   ├── WhitelistManagerView.swift
│   └── InAppAlertView.swift
├── Widget/                      # Widget扩展
│   ├── OrangeReminderWidget.swift
│   └── Info.plist
└── Info.plist                   # 应用配置
```

## 📋 使用要求

- iOS 15.0+
- Xcode 14.0+
- Swift 5.7+
- iCloud Drive（用于备份功能，可选）

## 🚀 安装与运行

### 1. 克隆项目
```bash
git clone https://github.com/Anpoliros/OrangeReminder.git
cd OrangeReminder
```

### 2. 配置 Xcode
```bash
open OrangeReminder.xcodeproj
```

### 3. 配置证书和能力
- 在 Xcode 中设置你的开发团队
- 修改 Bundle Identifier
- 启用以下 Capabilities:
  - ✅ Push Notifications
  - ✅ Background Modes
  - ✅ App Groups (`group.com.orangereminder.shared`)
  - ✅ iCloud (iCloud Documents)

### 4. 配置 Widget Extension
- 确保 Widget target 使用相同的 App Group
- 配置 Widget Bundle Identifier

### 5. 运行
- 选择目标设备或模拟器
- 运行主应用 (⌘R)
- 添加 Widget 到主屏幕

## 📖 使用指南

### 首次设置

1. **授予权限**
   - 启动应用后会请求通知权限
   - 建议全部允许以获得最佳体验

2. **选择或创建提醒组**
   - 在"提醒组"Tab查看预设模板
   - 点击"添加"创建自己的提醒组
   - 或使用快速模板

3. **配置白名单（可选）**
   - 进入"设置" > "应用白名单"
   - 添加不需要计时的应用

4. **添加 Widget 到桌面**
   - 长按主屏幕
   - 点击左上角"+"
   - 搜索"OrangeReminder"
   - 选择小号或中号Widget

### 日常使用

#### 快速切换状态
- **方式一**: 主屏幕Widget一键切换
- **方式二**: 应用内"当前提醒"Tab顶部开关
- **方式三**: "设置"Tab快捷开关

#### 切换提醒组
- 在"当前提醒"Tab点击提醒组卡片
- 从列表中选择要激活的提醒组
- 立即生效

#### 使用情景模式
1. 激活包含情景模式的提醒组（如工作模式）
2. 点击"开始情景模式"
3. 按照时间表工作和休息
4. 支持跳过当前阶段或重新开始

#### 管理白名单
1. 进入"设置" > "应用白名单"
2. 点击"+"添加新应用
3. 选择分类、图标和名称
4. 白名单应用的使用时间不会被统计

#### 备份到 iCloud
1. 进入"设置"Tab
2. 点击"备份到iCloud"
3. 等待同步完成
4. 在其他设备上可以"从iCloud恢复"

## 🎯 使用场景

### 场景 1: 工作时段
- 激活"工作模式"提醒组
- 启用情景模式（40-5-40-15循环）
- 生产力工具加入白名单
- 专注工作，定时休息

### 场景 2: 学习备考
- 使用"学习模式"提醒组
- 番茄钟式学习（25-5循环）
- 学习应用不计时
- 保持高效学习节奏

### 场景 3: 睡前放松
- 切换到"睡前模式"
- 30分钟限制+组合提醒
- 只允许冥想和睡眠音乐
- 避免过度使用影响睡眠

### 场景 4: 周末自由
- 使用"自由模式"
- 放宽时间限制
- 适度娱乐
- 仍有温和提醒

## 🔒 隐私说明

- ✅ 所有数据仅存储在本地和您的iCloud账户
- ✅ 不收集任何个人信息
- ✅ 不上传数据到第三方服务器
- ✅ 完全离线工作（除iCloud同步外）
- ✅ 开源透明，代码可审查

## ⚠️ 重要说明

### 关于 CallKit
虽然 CallKit 可以显示全屏来电界面，但：
- ⚠️ Apple 规定仅用于 VoIP 通话应用
- ⚠️ 滥用会导致应用被拒或下架
- ✅ 本应用使用合规的提醒方式
- ✅ "组合提醒"已经足够有效

### 关于 Screen Time API
- iOS 提供官方 Screen Time API (DeviceActivity)
- 需要特殊 entitlement 和 Apple 审批
- 本应用使用应用生命周期追踪
- 未来版本可能集成官方 API

### 关于白名单
- 当前版本白名单基于应用名称
- 实际应用使用时间由系统级追踪决定
- 白名单主要用于提醒组的个性化配置

## 🚧 已知限制

1. **后台追踪**: 应用在后台时，追踪会暂停
2. **应用识别**: 无法自动识别其他应用，需手动添加白名单
3. **跨设备**: 使用时间不跨设备同步（每台设备独立计时）
4. **系统权限**: 无法访问系统级使用时间数据

## 🛠️ 未来计划

### v2.1（近期）
- [ ] 使用统计图表（日/周/月）
- [ ] 更多预设模板
- [ ] 导入/导出提醒组
- [ ] 深色模式优化

### v2.5（中期）
- [ ] Apple Watch 支持
- [ ] 家庭共享功能
- [ ] 使用报告邮件提醒
- [ ] Siri Shortcuts 支持

### v3.0（远期）
- [ ] Screen Time API 集成
- [ ] 应用分类统计
- [ ] AI 智能建议
- [ ] 社交功能（挑战、排行）

## 🐛 问题反馈

如遇到问题或有功能建议，请：
- 提交 [GitHub Issue](https://github.com/Anpoliros/OrangeReminder/issues)
- 包含详细的问题描述和复现步骤
- 附上系统版本和应用版本号

## 🤝 贡献

欢迎贡献代码！请遵循以下步骤：

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

## 📄 许可证

MIT License - 详见 [LICENSE](LICENSE) 文件

## 👨‍💻 开发团队

**OrangeReminder Team**

- 核心开发: Claude + Human Collaboration
- UI/UX 设计: SwiftUI Best Practices
- 图标设计: SF Symbols

## 🙏 致谢

- Apple 的 SwiftUI 框架
- iOS Developer Community
- 所有提供反馈的用户

## 📞 联系方式

- GitHub: [@Anpoliros](https://github.com/Anpoliros)
- Issues: [项目Issues页面](https://github.com/Anpoliros/OrangeReminder/issues)

---

**让我们一起养成健康的手机使用习惯！** 🍊✨

*OrangeReminder - 您的数字健康守护者*
