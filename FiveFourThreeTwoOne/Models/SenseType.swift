import Foundation

enum SenseType: Int, Codable, CaseIterable, Identifiable {
    case see = 5
    case touch = 4
    case hear = 3
    case smell = 2
    case taste = 1

    var id: Int { rawValue }

    var stepIndex: Int {
        switch self {
        case .see: return 0
        case .touch: return 1
        case .hear: return 2
        case .smell: return 3
        case .taste: return 4
        }
    }

    var count: Int { rawValue }

    var displayName: String {
        switch self {
        case .see: return "See"
        case .touch: return "Touch / Feel"
        case .hear: return "Hear"
        case .smell: return "Smell"
        case .taste: return "Taste"
        }
    }

    var sfSymbol: String {
        switch self {
        case .see: return "eye.fill"
        case .touch: return "hand.point.up.braille.fill"
        case .hear: return "waveform.and.mic"
        case .smell: return "wind"
        case .taste: return "mouth.fill"
        }
    }

    var guidancePrompt: String {
        switch self {
        case .see: return "Take a moment. Look around you. Name 5 things you can see."
        case .touch: return "Now focus on touch. Name 4 things you can feel right now."
        case .hear: return "Listen carefully. Name 3 things you can hear."
        case .smell: return "Breathe in gently. Name 2 things you can smell."
        case .taste: return "Finally, notice 1 thing you can taste."
        }
    }

    var promptFileName: String {
        switch self {
        case .see: return "see"
        case .touch: return "touch"
        case .hear: return "hear"
        case .smell: return "smell"
        case .taste: return "taste"
        }
    }

    /// URL for the bundled default AI-voiced prompt, if present in the app bundle.
    var bundledPromptURL: URL? {
        Bundle.main.url(forResource: "default_\(promptFileName)", withExtension: "mp3")
    }

    static var orderedCases: [SenseType] {
        allCases.sorted { $0.stepIndex < $1.stepIndex }
    }
}
