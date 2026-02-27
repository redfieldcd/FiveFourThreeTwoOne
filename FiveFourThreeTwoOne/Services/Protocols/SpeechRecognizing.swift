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

    func requestAuthorization() async -> Bool
    func startTranscribing() throws
    func stopTranscribing() async -> String
}
