import SwiftUI

extension Color {
    static let appBackground = Color("AppBackground", bundle: nil)
    static let appAccent = Color("AppAccent", bundle: nil)
    static let appCardBackground = Color("AppCardBackground", bundle: nil)

    // Earth-tone palette for the five senses
    static let senseColors: [SenseType: Color] = [
        .see:   Color(hex: 0xCABFB4),  // warm gray
        .touch: Color(hex: 0xC89A74),  // tan
        .hear:  Color(hex: 0xB06835),  // warm brown
        .smell: Color(hex: 0x6A4C36),  // dark brown
        .taste: Color(hex: 0x302114)   // espresso
    ]

    static let senseGradients: [SenseType: [Color]] = [
        .see:   [Color(hex: 0xCABFB4), Color(hex: 0xD8CFC6)],
        .touch: [Color(hex: 0xC89A74), Color(hex: 0xD4AD8A)],
        .hear:  [Color(hex: 0xB06835), Color(hex: 0xC47D4D)],
        .smell: [Color(hex: 0x6A4C36), Color(hex: 0x7E5E48)],
        .taste: [Color(hex: 0x302114), Color(hex: 0x463325)]
    ]

    static func senseColor(for type: SenseType) -> Color {
        senseColors[type] ?? .accentColor
    }

    static func senseGradient(for type: SenseType) -> LinearGradient {
        let colors = senseGradients[type] ?? [.accentColor, .accentColor]
        return LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    // MARK: - Hex Initializer

    init(hex: UInt, opacity: Double = 1.0) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue: Double(hex & 0xFF) / 255.0,
            opacity: opacity
        )
    }
}
