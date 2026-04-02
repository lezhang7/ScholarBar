import SwiftUI

struct StatCard: View {
    let icon: String
    let label: String
    let value: Int
    let gradient: LinearGradient

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(.white.opacity(0.9))

            Text("\(value)")
                .font(Theme.statNumber)
                .foregroundStyle(.white)
                .contentTransition(.numericText(value: Double(value)))
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: value)

            Text(label)
                .font(Theme.statLabel)
                .foregroundStyle(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(gradient)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cardCornerRadius, style: .continuous))
        .shadow(color: .black.opacity(0.15), radius: Theme.cardShadow, y: 2)
    }
}
