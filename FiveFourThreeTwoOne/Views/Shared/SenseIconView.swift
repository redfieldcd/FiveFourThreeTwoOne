import SwiftUI

struct SenseIconView: View {
    let senseType: SenseType
    var size: CGFloat = 48

    @Environment(AppSettings.self) private var appSettings

    var body: some View {
        let base = appSettings.backgroundColor
        let senseColor = Color.senseColor(for: senseType)
        let darkShadow = Color.black.opacity(0.15)
        let lightShadow = Color.white.opacity(0.7)

        Image(systemName: senseType.sfSymbol)
            .font(.system(size: size * 0.38, weight: .semibold))
            .foregroundStyle(senseColor)
            .frame(width: size, height: size)
            .background(
                RoundedRectangle(cornerRadius: size * 0.28, style: .continuous)
                    .fill(base)
            )
            .overlay(
                RoundedRectangle(cornerRadius: size * 0.28, style: .continuous)
                    .stroke(Color.white.opacity(0.4), lineWidth: 0.5)
            )
            // Neumorphic double-shadow: dark bottom-right, light top-left
            .shadow(color: darkShadow, radius: size * 0.12, x: size * 0.06, y: size * 0.06)
            .shadow(color: lightShadow, radius: size * 0.12, x: -size * 0.04, y: -size * 0.04)
            .accessibilityLabel("Sense: \(senseType.displayName)")
    }
}
