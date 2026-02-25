import Foundation
@testable import FiveFourThreeTwoOne

final class MockAudioRecorder: AudioRecording {
    var isRecording: Bool = false
    var startRecordingCallCount = 0
    var stopRecordingCallCount = 0
    var recordedURL: URL?

    func startRecording(to fileURL: URL) throws {
        startRecordingCallCount += 1
        recordedURL = fileURL
        isRecording = true
    }

    func stopRecording() -> URL? {
        stopRecordingCallCount += 1
        isRecording = false
        return recordedURL
    }
}
