import Foundation
@testable import FiveFourThreeTwoOne

final class MockSpeechRecognizer: SpeechRecognizing {
    var status: SpeechRecognitionStatus = .notStarted
    var authorizationResult: Bool = true
    var transcriptionResults: [String] = ["Hello world"]
    var itemCountResults: [Int] = [1]
    private var continuation: AsyncStream<String>.Continuation?
    private var itemCountContinuation: AsyncStream<Int>.Continuation?

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

    var itemCountStream: AsyncStream<Int> {
        AsyncStream { continuation in
            self.itemCountContinuation = continuation
            for count in self.itemCountResults {
                continuation.yield(count)
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
        itemCountContinuation?.finish()
        status = .notStarted
        return transcriptionResults.last ?? ""
    }
}
