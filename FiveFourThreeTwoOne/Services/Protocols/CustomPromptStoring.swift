import Foundation

protocol CustomPromptStoring: AnyObject {
    func fileURL(for senseType: SenseType) -> URL
    func hasCustomPrompt(for senseType: SenseType) -> Bool
    func deleteCustomPrompt(for senseType: SenseType) throws
    func ensureDirectoryExists() throws
}
