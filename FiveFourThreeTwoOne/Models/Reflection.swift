import Foundation
import SwiftData

@Model
final class Reflection {
    var title: String
    var createdAt: Date
    var isComplete: Bool
    var locationName: String?

    @Relationship(deleteRule: .cascade, inverse: \SenseEntry.reflection)
    var entries: [SenseEntry]

    var journalText: String {
        entries
            .sorted { $0.senseType.stepIndex < $1.senseType.stepIndex }
            .map { entry in
                let header = "\(entry.senseType.count) thing(s) I could \(entry.senseType.displayName.lowercased()):"
                return "\(header)\n\(entry.transcribedText)"
            }
            .joined(separator: "\n\n")
    }

    /// Display name: location if available, otherwise falls back to title.
    var displayTitle: String {
        if let locationName, !locationName.isEmpty {
            return locationName
        }
        return title
    }

    init(title: String = "", createdAt: Date = .now,
         isComplete: Bool = false, locationName: String? = nil,
         entries: [SenseEntry] = []) {
        self.title = title
        self.createdAt = createdAt
        self.isComplete = isComplete
        self.locationName = locationName
        self.entries = entries
    }
}
