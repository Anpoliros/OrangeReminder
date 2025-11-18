.PHONY: help open build run clean test

help:
	@echo "OrangeReminder - Makefile 命令"
	@echo ""
	@echo "使用方法:"
	@echo "  make open    - 在 Xcode 中打开项目"
	@echo "  make build   - 构建项目"
	@echo "  make run     - 运行项目"
	@echo "  make clean   - 清理构建文件"
	@echo "  make test    - 运行测试"
	@echo ""

open:
	@echo "🚀 在 Xcode 中打开项目..."
	@open OrangeReminder.xcodeproj

build:
	@echo "🔨 构建项目..."
	@xcodebuild -project OrangeReminder.xcodeproj \
		-scheme OrangeReminder \
		-destination 'platform=iOS Simulator,name=iPhone 15' \
		build

run:
	@echo "▶️  运行项目..."
	@xcodebuild -project OrangeReminder.xcodeproj \
		-scheme OrangeReminder \
		-destination 'platform=iOS Simulator,name=iPhone 15' \
		run

clean:
	@echo "🧹 清理构建文件..."
	@xcodebuild -project OrangeReminder.xcodeproj \
		-scheme OrangeReminder \
		clean
	@rm -rf build/
	@rm -rf DerivedData/
	@echo "✅ 清理完成"

test:
	@echo "🧪 运行测试..."
	@xcodebuild -project OrangeReminder.xcodeproj \
		-scheme OrangeReminder \
		-destination 'platform=iOS Simulator,name=iPhone 15' \
		test

devices:
	@echo "📱 可用设备列表:"
	@xcodebuild -showdestinations -scheme OrangeReminder | grep "platform"

version:
	@echo "📦 项目版本: 2.0.0"
	@xcodebuild -version
