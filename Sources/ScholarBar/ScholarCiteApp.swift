import SwiftUI
import AppKit

@main
struct ScholarBarApp: App {
    @StateObject private var store = CitationStore()

    var body: some Scene {
        MenuBarExtra {
            MainView(store: store)
                .onAppear {
                    store.dismissBadge()
                }
        } label: {
            MenuBarLabel(
                count: store.totalCitations,
                hasNew: store.hasNewCitations,
                diff: store.newCitationsDiff
            )
        }
        .menuBarExtraStyle(.window)
    }
}

struct MenuBarLabel: View {
    let count: Int
    let hasNew: Bool
    let diff: Int

    var body: some View {
        HStack(spacing: 2) {
            Image(systemName: "graduationcap.fill")
                .font(.system(size: 11))
            if count > 0 {
                Text(formatCount(count))
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .monospacedDigit()
            }
            if hasNew {
                Text("+\(diff)")
                    .font(.system(size: 9, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 1)
                    .background(Capsule().fill(.red))
            }
        }
    }

    private func formatCount(_ n: Int) -> String {
        if n >= 10000 {
            return String(format: "%.1fk", Double(n) / 1000)
        }
        return "\(n)"
    }
}
