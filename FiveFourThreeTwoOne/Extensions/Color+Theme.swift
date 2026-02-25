import SwiftUI

extension Color {
    static let appBackground = Color("AppBackground", bundle: nil)
    static let appAccent = Color("AppAccent", bundle: nil)
    static let appCardBackground = Color("AppCardBackground", bundle: nil)

    static let senseColors: [SenseType: Color] = [
        .see: Color(red: 0.25, green: 0.52, blue: 0.96),
        .touch: Color(red: 0.96, green: 0.58, blue: 0.12),
        .hear: Color(red: 0.18, green: 0.80, blue: 0.60),
        .smell: Color(red: 0.65, green: 0.35, blue: 0.90),
        .taste: Color(red: 0.95, green: 0.35, blue: 0.50)
    ]

    static let senseGradients: [SenseType: [Color]] = [
        .see: [Color(red: 0.25, green: 0.52, blue: 0.96), Color(red: 0.45, green: 0.72, blue: 1.0)],
        .touch: [Color(red: 0.96, green: 0.58, blue: 0.12), Color(red: 1.0, green: 0.78, blue: 0.36)],
        .hear: [Color(red: 0.18, green: 0.80, blue: 0.60), Color(red: 0.40, green: 0.92, blue: 0.75)],
        .smell: [Color(red: 0.65, green: 0.35, blue: 0.90), Color(red: 0.82, green: 0.55, blue: 1.0)],
        .taste: [Color(red: 0.95, green: 0.35, blue: 0.50), Color(red: 1.0, green: 0.55, blue: 0.65)]
    ]

    static func senseColor(for type: SenseType) -> Color {
        senseColors[type] ?? .accentColor
    }

    static func senseGradient(for type: SenseType) -> LinearGradient {
        let colors = senseGradients[type] ?? [.accentColor, .accentColor]
        return LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}
