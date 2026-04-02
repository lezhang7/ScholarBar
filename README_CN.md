# ScholarBar

一个 macOS 菜单栏应用，实时监控你的 Google Scholar 引用数变化。

![macOS](https://img.shields.io/badge/macOS-15.0%2B-blue) ![Swift](https://img.shields.io/badge/Swift-6.0-orange) ![License](https://img.shields.io/badge/License-MIT-green)

[English](README.md) | 中文

## 功能特性

- **菜单栏引用计数器** — 在菜单栏直接显示总引用数（🎓 1234）
- **精美统计面板** — 渐变色卡片展示总引用数、h-index、i10-index
- **智能通知** — 引用数增长时发送系统通知，菜单栏显示红色气泡（+N）
- **自动刷新** — 可配置刷新间隔（15分钟 / 30分钟 / 1小时 / 2小时）
- **灵活输入** — 直接粘贴 Google Scholar 链接或输入 User ID
- **开机自启** — 支持设置开机自动启动
- **轻量原生** — 纯 Swift + SwiftUI，无任何外部依赖

## 安装

### 方式一：下载 DMG（推荐）

1. 前往 [Releases](../../releases) 下载 `ScholarBar.dmg`
2. 打开 DMG，将 `ScholarBar.app` 拖入 `/Applications`
3. 首次启动：右键点击应用 → 打开（未签名应用需绕过 Gatekeeper）

### 方式二：从源码编译

```bash
git clone https://github.com/lezhang7/ScholarBar.git
cd ScholarBar
swift build -c release
```

或使用构建脚本生成 `.app` + DMG：

```bash
./build_release.sh
```

## 使用方法

1. 启动应用 — 菜单栏出现毕业帽图标 🎓
2. 点击图标 → **设置**
3. 输入你的 Google Scholar User ID 或直接粘贴个人主页链接
   - 示例 ID：`NqbBXAsAAAAJ`
   - 示例链接：`https://scholar.google.com/citations?user=NqbBXAsAAAAJ&hl=en`
4. 完成！应用会立即获取数据并定时自动刷新

## 如何找到你的 Scholar User ID

1. 打开 [Google Scholar](https://scholar.google.com/)
2. 点击你的个人主页
3. 查看 URL：`https://scholar.google.com/citations?user=`**`NqbBXAsAAAAJ`**`&hl=en`
4. `user=` 后面的那串字符就是你的 User ID

## 系统要求

- macOS 15.0+
- 网络连接（用于获取 Google Scholar 数据）

## 技术栈

- Swift 6.0 / SwiftUI
- `MenuBarExtra`（`.window` 样式）实现富弹出面板
- `URLSession` + 正则 HTML 解析抓取 Google Scholar
- `UNUserNotificationCenter` 系统通知
- `SMAppService` 开机自启
- `UserDefaults` 数据持久化

## 许可证

MIT
