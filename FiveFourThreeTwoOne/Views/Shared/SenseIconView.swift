import SwiftUI

struct SenseIconView: View {
    let senseType: SenseType
    var size: CGFloat = 48

    var body: some View {
        Image(systemName: senseType.sfSymbol)
            .font(.system(size: size * 0.4, weight: .semibold))
            .foregroundStyle(.white)
            .frame(width: size, height: size)
            .background(
                RoundedRectangle(cornerRadius: size * 0.28, style: .continuous)
                    .fill(Color.senseGradient(for: senseType))
            )
            .overlay(
                RoundedRectangle(cornerRadius: size * 0.28, style: .continuous)
                    .stroke(.white.opacity(0.25), lineWidth: 0.5)
            )
            .shadow(color: Color.senseColor(for: senseType).opacity(0.35), radius: size * 0.15, y: size * 0.08)
            .accessibilityLabel("Sense: \(senseType.displayName)")
    }
}
