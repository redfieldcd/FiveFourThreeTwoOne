import Foundation
@testable import FiveFourThreeTwoOne

final class MockSpeechRecognizer: SpeechRecognizing {
    var status: SpeechRecognitionStatus = .notStarted
    var authorizationResult: Bool = true
    var transcriptionResults: [String] = ["Hello world"]
    private var continuation: AsyncStream<String>.Continuation?

    var startTranscribingCallCount = 0
    var stopTranscribingCallCount = 0

    var transcriptionStream: AsyncStream<String> {
        AsyncStream { continuation in
            self.continuation = continuation
            for result in self.transcriptionResults {
                continuation.yield(result)
            }
            continuation.finish()
        }
    }

    func requestAuthorization() async -> Bool {
        authorizationResult
    }

    func startTranscribing() throws {
        startTranscribingCallCount += 1
        status = .recording
    }

    func stopTranscribing() async -> String {
        stopTranscribingCallCount += 1
        continuation?.finish()
        status = .notStarted
        return transcriptionResults.last ?? ""
    }
}
