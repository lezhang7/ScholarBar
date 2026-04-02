# ScholarCite

A macOS menu bar app that monitors your Google Scholar citations in real-time.

![macOS](https://img.shields.io/badge/macOS-15.0%2B-blue) ![Swift](https://img.shields.io/badge/Swift-6.0-orange) ![License](https://img.shields.io/badge/License-MIT-green)

## Features

- **Menu Bar Citation Counter** — Shows your total citation count with a graduation cap icon directly in the menu bar
- **Live Stats Dashboard** — Beautiful gradient cards displaying total citations, h-index, and i10-index
- **Smart Notifications** — System notifications when your citations grow, with a red badge (+N) on the menu bar icon
- **Auto Refresh** — Configurable refresh interval (15min / 30min / 1h / 2h)
- **Flexible Input** — Paste your full Google Scholar URL or just the User ID
- **Launch at Login** — Optional auto-start on macOS login
- **Lightweight** — Pure Swift + SwiftUI, no external dependencies

## Install

### Option 1: Download DMG (Recommended)

1. Go to [Releases](../../releases) and download `ScholarCite.dmg`
2. Open the DMG and drag `ScholarCite.app` to `/Applications`
3. First launch: right-click the app → Open (to bypass Gatekeeper for unsigned apps)

### Option 2: Build from Source

```bash
git clone https://github.com/YOUR_USERNAME/ScholarCite.git
cd ScholarCite
swift build -c release
```

Or use the build script to generate a `.app` bundle + DMG:

```bash
./build_release.sh
```

## Setup

1. Launch the app — a graduation cap icon appears in your menu bar
2. Click the icon → **Settings**
3. Enter your Google Scholar User ID or paste your profile URL
   - Example ID: `NqbBXAsAAAAJ`
   - Example URL: `https://scholar.google.com/citations?user=NqbBXAsAAAAJ&hl=en`
4. Done! The app will fetch your stats immediately and auto-refresh periodically

## How to Find Your Scholar User ID

1. Go to [Google Scholar](https://scholar.google.com/)
2. Click your profile
3. Look at the URL: `https://scholar.google.com/citations?user=`**`NqbBXAsAAAAJ`**`&hl=en`
4. The part after `user=` is your User ID

## Requirements

- macOS 15.0+
- Internet connection (to fetch Google Scholar data)

## Tech Stack

- Swift 6.0 / SwiftUI
- `MenuBarExtra` with `.window` style for rich popup UI
- `URLSession` + regex HTML parsing for Google Scholar
- `UNUserNotificationCenter` for system notifications
- `SMAppService` for launch-at-login
- `UserDefaults` for persistence

## License

MIT
