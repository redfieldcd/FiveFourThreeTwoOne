import SwiftData
@testable import FiveFourThreeTwoOne

enum TestModelContainer {
    static func create() throws -> ModelContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        return try ModelContainer(
            for: Reflection.self, SenseEntry.self,
            configurations: config
        )
    }
}
