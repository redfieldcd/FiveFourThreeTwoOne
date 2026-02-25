import SwiftUI
import SwiftData

@MainActor
@Observable
final class HomeViewModel {
    private let modelContext: ModelContext

    var reflections: [Reflection] = []

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetchReflections() {
        let descriptor = FetchDescriptor<Reflection>(
            predicate: #Predicate { $0.isComplete == true },
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        reflections = (try? modelContext.fetch(descriptor)) ?? []
    }

    func deleteReflection(_ reflection: Reflection) {
        for entry in reflection.entries {
            if let url = entry.audioFileURL {
                try? FileManager.default.removeItem(at: url)
            }
        }
        modelContext.delete(reflection)
        try? modelContext.save()
        fetchReflections()
    }
}
