import Foundation

protocol VoiceGuiding: AnyObject {
    var isSpeaking: Bool { get }

    func speak(_ text: String) async
    func speak(_ text: String, for senseType: SenseType) async
    func stopSpeaking()
}

extension VoiceGuiding {
    func speak(_ text: String, for senseType: SenseType) async {
        await speak(text)
    }
}
