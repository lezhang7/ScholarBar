import SwiftUI

struct MainView: View {
    @ObservedObject var store: CitationStore
    @State private var currentPage: Page = .main
    @State private var rotationAngle: Double = 0

    enum Page {
        case main, settings
    }

    var body: some View {
        VStack(spacing: 0) {
            switch currentPage {
            case .main:
                mainContent
            case .settings:
                settingsContent
            }
        }
        .frame(width: Theme.panelWidth)
        .animation(.easeInOut(duration: 0.2), value: currentPage)
    }

    // MARK: - Main Content

    @ViewBuilder
    private var mainContent: some View {
        VStack(spacing: 0) {
            // Header
            headerSection
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 12)

            if store.isConfigured {
                // Stat Cards
                HStack(spacing: 10) {
                    StatCard(
                        icon: "quote.bubble.fill",
                        label: "总引用",
                        value: store.totalCitations,
                        gradient: Theme.citationGradient
                    )
                    StatCard(
                        icon: "chart.bar.fill",
                        label: "h-index",
                        value: store.hIndex,
                        gradient: Theme.hIndexGradient
                    )
                    StatCard(
                        icon: "star.fill",
                        label: "i10-index",
                        value: store.i10Index,
                        gradient: Theme.i10Gradient
                    )
                }
                .padding(.horizontal, 16)

                // Status
                statusSection
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
            } else {
                emptyState
                    .padding(.horizontal, 16)
            }

            Spacer(minLength: 8)

            Divider()

            // Toolbar
            toolbar
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
        }
        .frame(height: store.isConfigured ? 280 : 240)
    }

    // MARK: - Settings Content (inline, no sheet)

    @ViewBuilder
    private var settingsContent: some View {
        SettingsView(store: store) {
            currentPage = .main
        }
    }

    // MARK: - Header

    @ViewBuilder
    private var headerSection: some View {
        HStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(Theme.citationGradient)
                    .frame(width: 40, height: 40)
                Text(avatarInitial)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 2) {
                if store.userName.isEmpty {
                    Text("ScholarCite")
                        .font(Theme.headerName)
                } else {
                    Text(store.userName)
                        .font(Theme.headerName)
                        .lineLimit(1)
                }
                if let url = store.scholarURL {
                    Link("Google Scholar Profile", destination: url)
                        .font(Theme.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()
        }
    }

    private var avatarInitial: String {
        guard let first = store.userName.first else { return "S" }
        return String(first).uppercased()
    }

    // MARK: - Status

    @ViewBuilder
    private var statusSection: some View {
        HStack {
            if let error = store.errorMessage {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.orange)
                    .font(.caption)
                Text(error)
                    .font(Theme.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            } else {
                Image(systemName: "clock")
                    .foregroundStyle(.secondary)
                    .font(.caption)
                Text("更新于 \(store.lastUpdatedText)")
                    .font(Theme.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
    }

    // MARK: - Empty State

    @ViewBuilder
    private var emptyState: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "person.crop.circle.badge.questionmark")
                .font(.system(size: 40))
                .foregroundStyle(.secondary)
            Text("请先配置 Scholar User ID")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(.secondary)
            Button("打开设置") {
                currentPage = .settings
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.regular)
            Spacer()
        }
    }

    // MARK: - Toolbar

    @ViewBuilder
    private var toolbar: some View {
        HStack(spacing: 4) {
            Button {
                Task {
                    withAnimation(.linear(duration: 0.8).repeatCount(3, autoreverses: false)) {
                        rotationAngle += 360
                    }
                    await store.refresh()
                }
            } label: {
                Group {
                    if store.isLoading {
                        ProgressView()
                            .controlSize(.small)
                            .frame(width: 16, height: 16)
                    } else {
                        Image(systemName: "arrow.clockwise")
                            .rotationEffect(.degrees(rotationAngle))
                    }
                }
                .frame(width: 28, height: 28)
            }
            .buttonStyle(.plain)
            .disabled(store.isLoading || !store.isConfigured)
            .help("刷新")

            Button {
                currentPage = .settings
            } label: {
                Image(systemName: "gearshape.fill")
                    .frame(width: 28, height: 28)
            }
            .buttonStyle(.plain)
            .help("设置")

            Spacer()

            Button {
                NSApplication.shared.terminate(nil)
            } label: {
                Image(systemName: "power")
                    .frame(width: 28, height: 28)
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            .help("退出")
        }
    }
}
