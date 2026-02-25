import Foundation
@testable import FiveFourThreeTwoOne

final class MockCustomPromptStorage: CustomPromptStoring {
    var existingPrompts: Set<SenseType> = []
    var deleteCallCount = 0
    var lastDeletedSenseType: SenseType?

    func fileURL(for senseType: SenseType) -> URL {
        URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("CustomPrompts")
            .appendingPathComponent("\(senseType.promptFileName).m4a")
    }

    func hasCustomPrompt(for senseType: SenseType) -> Bool {
        existingPrompts.contains(senseType)
    }

    func deleteCustomPrompt(for senseType: SenseType) throws {
        deleteCallCount += 1
        lastDeletedSenseType = senseType
        existingPrompts.remove(senseType)
    }

    func ensureDirectoryExists() throws {}
}
