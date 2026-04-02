import SwiftUI

struct SettingsView: View {
    @ObservedObject var store: CitationStore
    var onBack: () -> Void

    @State private var draftInput: String = ""
    @State private var inputError: String? = nil

    private let intervalOptions: [(label: String, minutes: Int)] = [
        ("15 分钟", 15),
        ("30 分钟", 30),
        ("1 小时", 60),
        ("2 小时", 120),
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Title bar with back button
            HStack {
                Button {
                    onBack()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 13, weight: .semibold))
                        Text("返回")
                            .font(.system(size: 13))
                    }
                }
                .buttonStyle(.plain)
                .foregroundStyle(.blue)

                Spacer()

                Text("设置")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))

                Spacer()

                // Invisible spacer for centering
                Text("返回").font(.system(size: 13)).hidden()
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)
            .padding(.bottom, 10)

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // MARK: - Scholar ID
                    settingSection("Scholar 配置", icon: "person.circle.fill") {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Google Scholar User ID 或链接")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(.secondary)
                            HStack(spacing: 8) {
                                TextField("User ID 或 Scholar 主页链接", text: $draftInput)
                                    .textFieldStyle(.roundedBorder)
                                    .font(.system(size: 13, design: .monospaced))
                                    .onChange(of: draftInput) {
                                        inputError = nil
                                    }
                                Button("保存") {
                                    saveScholarInput()
                                }
                                .buttonStyle(.borderedProminent)
                                .controlSize(.small)
                                .disabled(draftInput.trimmingCharacters(in: .whitespaces).isEmpty)
                            }
                            if let error = inputError {
                                Text(error)
                                    .font(.system(size: 11))
                                    .foregroundStyle(.red)
                            } else {
                                Text("支持粘贴完整链接或仅输入 User ID（如 NqbBXAsAAAAJ）")
                                    .font(.system(size: 11))
                                    .foregroundStyle(.tertiary)
                            }
                            if !store.scholarUserID.isEmpty {
                                HStack(spacing: 4) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.green)
                                        .font(.system(size: 11))
                                    Text("当前 ID: \(store.scholarUserID)")
                                        .font(.system(size: 11, design: .monospaced))
                                        .foregroundStyle(.secondary)
                                }
                                .padding(.top, 2)
                            }
                        }
                    }

                    // MARK: - Refresh Interval
                    settingSection("刷新间隔", icon: "clock.arrow.circlepath") {
                        Picker("", selection: $store.refreshIntervalMinutes) {
                            ForEach(intervalOptions, id: \.minutes) { option in
                                Text(option.label).tag(option.minutes)
                            }
                        }
                        .pickerStyle(.segmented)
                        .labelsHidden()
                    }

                    // MARK: - Toggles
                    settingSection("通用", icon: "slider.horizontal.3") {
                        VStack(spacing: 10) {
                            Toggle(isOn: $store.launchAtLogin) {
                                HStack(spacing: 6) {
                                    Image(systemName: "sunrise.fill")
                                        .foregroundStyle(.orange)
                                        .font(.system(size: 13))
                                    Text("开机自动启动")
                                        .font(.system(size: 13))
                                }
                            }
                            .toggleStyle(.switch)
                            .controlSize(.small)

                            Toggle(isOn: $store.notificationsEnabled) {
                                HStack(spacing: 6) {
                                    Image(systemName: "bell.badge.fill")
                                        .foregroundStyle(.red)
                                        .font(.system(size: 13))
                                    Text("引用增长通知")
                                        .font(.system(size: 13))
                                }
                            }
                            .toggleStyle(.switch)
                            .controlSize(.small)
                        }
                    }
                }
                .padding(16)
            }
        }
        .frame(height: 400)
        .onAppear {
            draftInput = store.scholarUserID
        }
    }

    private func saveScholarInput() {
        let input = draftInput.trimmingCharacters(in: .whitespaces)
        guard !input.isEmpty else { return }

        if let userID = extractUserID(from: input) {
            inputError = nil
            store.scholarUserID = userID
            draftInput = userID
        } else {
            inputError = "无法识别 User ID，请检查输入"
        }
    }

    /// Extract user ID from various input formats:
    /// - Direct ID: "NqbBXAsAAAAJ"
    /// - Full URL: "https://scholar.google.com/citations?user=NqbBXAsAAAAJ&..."
    /// - URL with different params: "...?hl=en&user=NqbBXAsAAAAJ"
    private func extractUserID(from input: String) -> String? {
        // If it looks like a URL, try to extract user= param
        if input.contains("scholar.google") || input.contains("user=") {
            if let urlComponents = URLComponents(string: input),
               let userParam = urlComponents.queryItems?.first(where: { $0.name == "user" })?.value,
               !userParam.isEmpty {
                return userParam
            }
            // Fallback: regex for user= in messy URLs
            if let range = input.range(of: #"user=([A-Za-z0-9_-]+)"#, options: .regularExpression) {
                let match = input[range]
                return String(match.dropFirst(5)) // drop "user="
            }
            return nil
        }

        // Plain ID: alphanumeric, typically 12 chars
        let cleaned = input.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleaned.range(of: #"^[A-Za-z0-9_-]{6,}$"#, options: .regularExpression) != nil {
            return cleaned
        }

        return nil
    }

    @ViewBuilder
    private func settingSection<Content: View>(_ title: String, icon: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 13))
                    .foregroundStyle(.blue)
                Text(title)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
            }
            content()
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(nsColor: .controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}
