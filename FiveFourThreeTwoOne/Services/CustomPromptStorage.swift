import Foundation

final class CustomPromptStorage: CustomPromptStoring {
    private let baseDirectory: URL

    init() {
        self.baseDirectory = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("CustomPrompts", isDirectory: true)
    }

    init(baseDirectory: URL) {
        self.baseDirectory = baseDirectory
    }

    func fileURL(for senseType: SenseType) -> URL {
        baseDirectory.appendingPathComponent("\(senseType.promptFileName).m4a")
    }

    func hasCustomPrompt(for senseType: SenseType) -> Bool {
        FileManager.default.fileExists(atPath: fileURL(for: senseType).path)
    }

    func deleteCustomPrompt(for senseType: SenseType) throws {
        let url = fileURL(for: senseType)
        if FileManager.default.fileExists(atPath: url.path) {
            try FileManager.default.removeItem(at: url)
        }
    }

    func ensureDirectoryExists() throws {
        try FileManager.default.createDirectory(
            at: baseDirectory,
            withIntermediateDirectories: true
        )
    }
}
