import SwiftUI

@Observable
final class AppSettings {
    enum ColorTheme: Int, CaseIterable, Identifiable {
        case defaultWhite = 0
        case cosmicIndigo = 1
        case sakura = 2

        var id: Int { rawValue }

        var label: String {
            switch self {
            case .defaultWhite: return "Default"
            case .cosmicIndigo: return "Cosmic Indigo"
            case .sakura: return "Sakura"
            }
        }

        var iconName: String {
            switch self {
            case .defaultWhite: return "sun.max.fill"
            case .cosmicIndigo: return "moon.stars.fill"
            case .sakura: return "leaf.fill"
            }
        }

        /// The preferred color scheme, or nil to follow system.
        var colorScheme: ColorScheme? {
            switch self {
            case .defaultWhite: return .light
            case .cosmicIndigo: return .dark
            case .sakura: return .light
            }
        }

        // MARK: - Theme Colors

        var backgroundColor: Color {
            switch self {
            case .defaultWhite: return Color(.systemBackground)
            case .cosmicIndigo: return Color(red: 26/255, green: 26/255, blue: 46/255)   // #1A1A2E
            case .sakura: return Color(red: 250/255, green: 230/255, blue: 240/255)       // #FAE6F0
            }
        }

        var cardBackground: Color {
            switch self {
            case .defaultWhite: return Color(.secondarySystemBackground)
            case .cosmicIndigo: return Color(red: 37/255, green: 37/255, blue: 74/255)    // #25254A
            case .sakura: return Color(red: 240/255, green: 192/255, blue: 216/255)       // #F0C0D8
            }
        }

        var accentColor: Color {
            switch self {
            case .defaultWhite: return .accentColor
            case .cosmicIndigo: return Color(red: 124/255, green: 58/255, blue: 237/255)  // #7C3AED
            case .sakura: return Color(red: 219/255, green: 39/255, blue: 119/255)        // #DB2777
            }
        }

        var primaryText: Color {
            switch self {
            case .defaultWhite: return Color(.label)
            case .cosmicIndigo: return .white
            case .sakura: return Color(red: 60/255, green: 30/255, blue: 45/255)
            }
        }

        var secondaryText: Color {
            switch self {
            case .defaultWhite: return Color(.secondaryLabel)
            case .cosmicIndigo: return Color(white: 0.7)
            case .sakura: return Color(red: 120/255, green: 80/255, blue: 100/255)
            }
        }
    }

    var colorTheme: ColorTheme {
        get {
            access(keyPath: \.colorTheme)
            return ColorTheme(rawValue: _themeRawValue) ?? .defaultWhite
        }
        set {
            withMutation(keyPath: \.colorTheme) {
                _themeRawValue = newValue.rawValue
            }
        }
    }

    /// Convenience accessors
    var colorScheme: ColorScheme? { colorTheme.colorScheme }
    var backgroundColor: Color { colorTheme.backgroundColor }
    var cardBackground: Color { colorTheme.cardBackground }
    var themeAccentColor: Color { colorTheme.accentColor }

    @ObservationIgnored
    @AppStorage("appTheme") private var _themeRawValue: Int = ColorTheme.defaultWhite.rawValue
}
