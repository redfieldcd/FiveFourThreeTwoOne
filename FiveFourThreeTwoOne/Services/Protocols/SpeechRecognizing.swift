import Foundation

enum SpeechRecognitionStatus: Equatable {
    case notStarted
    case recording
    case stopping
    case unavailable(reason: String)
}

protocol SpeechRecognizing: AnyObject {
    var status: SpeechRecognitionStatus { get }
    var transcriptionStream: AsyncStream<String> { get }
    /// Emits the detected number of distinct items based on speech pauses and punctuation.
    var itemCountStream: AsyncStream<Int> { get }

    func requestAuthorization() async -> Bool
    func startTranscribing() throws
    func stopTranscribing() async -> String
}
