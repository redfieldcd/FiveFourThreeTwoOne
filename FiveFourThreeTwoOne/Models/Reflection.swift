import Foundation
import SwiftData

@Model
final class Reflection {
    var title: String
    var createdAt: Date
    var isComplete: Bool

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

    init(title: String = "", createdAt: Date = .now,
         isComplete: Bool = false, entries: [SenseEntry] = []) {
        self.title = title
        self.createdAt = createdAt
        self.isComplete = isComplete
        self.entries = entries
    }
}
