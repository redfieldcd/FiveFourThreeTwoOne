import Foundation
import SwiftData

@Model
final class SenseEntry {
    var senseTypeRaw: Int
    var transcribedText: String
    var audioFileName: String?
    var createdAt: Date

    var reflection: Reflection?

    var senseType: SenseType {
        get { SenseType(rawValue: senseTypeRaw) ?? .see }
        set { senseTypeRaw = newValue.rawValue }
    }

    var audioFileURL: URL? {
        guard let audioFileName else { return nil }
        return FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Audio")
            .appendingPathComponent(audioFileName)
    }

    init(senseType: SenseType, transcribedText: String = "",
         audioFileName: String? = nil, createdAt: Date = .now) {
        self.senseTypeRaw = senseType.rawValue
        self.transcribedText = transcribedText
        self.audioFileName = audioFileName
        self.createdAt = createdAt
    }
}
