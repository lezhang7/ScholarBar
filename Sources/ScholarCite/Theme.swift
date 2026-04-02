import SwiftUI

enum Theme {
    // MARK: - Gradients for stat cards
    static let citationGradient = LinearGradient(
        colors: [Color(hex: 0x667EEA), Color(hex: 0x764BA2)],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )

    static let hIndexGradient = LinearGradient(
        colors: [Color(hex: 0x11998E), Color(hex: 0x38EF7D)],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )

    static let i10Gradient = LinearGradient(
        colors: [Color(hex: 0xF2994A), Color(hex: 0xF2636E)],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )

    // MARK: - Panel
    static let panelBackground = Color(nsColor: .windowBackgroundColor)
    static let cardCornerRadius: CGFloat = 14
    static let panelCornerRadius: CGFloat = 16
    static let panelWidth: CGFloat = 380
    static let cardShadow: CGFloat = 4

    // MARK: - Typography
    static let statNumber = Font.system(size: 28, weight: .bold, design: .rounded)
    static let statLabel = Font.system(size: 12, weight: .medium, design: .rounded)
    static let headerName = Font.system(size: 16, weight: .semibold, design: .rounded)
    static let caption = Font.system(size: 11, weight: .regular, design: .rounded)
}

// MARK: - Color hex initializer
extension Color {
    init(hex: UInt, opacity: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: opacity
        )
    }
}
