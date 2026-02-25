import Foundation
@testable import FiveFourThreeTwoOne

final class MockVoiceGuide: VoiceGuiding {
    var isSpeaking: Bool = false
    var speakCallCount = 0
    var lastSpokenText: String?
    var lastSpokenSenseType: SenseType?
    var stopSpeakingCallCount = 0

    func speak(_ text: String) async {
        speakCallCount += 1
        lastSpokenText = text
        isSpeaking = true
        isSpeaking = false
    }

    func speak(_ text: String, for senseType: SenseType) async {
        speakCallCount += 1
        lastSpokenText = text
        lastSpokenSenseType = senseType
        isSpeaking = true
        isSpeaking = false
    }

    func stopSpeaking() {
        stopSpeakingCallCount += 1
        isSpeaking = false
    }
}
