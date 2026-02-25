import Foundation

enum AppConstants {
    static let appName = "5-4-3-2-1 Reflection"
    static let audioDirectoryName = "Audio"

    static var audioDirectoryURL: URL {
        FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(audioDirectoryName, isDirectory: true)
    }
}
