import AVFoundation

final class VoiceGuidanceService: NSObject, VoiceGuiding, AVSpeechSynthesizerDelegate, AVAudioPlayerDelegate {
    private let synthesizer = AVSpeechSynthesizer()
    private let customPromptStorage: any CustomPromptStoring
    private var audioPlayer: AVAudioPlayer?

    private var speakContinuation: CheckedContinuation<Void, Never>?
    private var playbackContinuation: CheckedContinuation<Void, Never>?

    private(set) var isSpeaking: Bool = false

    init(customPromptStorage: any CustomPromptStoring = CustomPromptStorage()) {
        self.customPromptStorage = customPromptStorage
        super.init()
        synthesizer.delegate = self
    }

    func speak(_ text: String) async {
        isSpeaking = true

        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.9
        utterance.pitchMultiplier = 1.0
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")

        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            self.speakContinuation = continuation
            synthesizer.speak(utterance)
        }

        isSpeaking = false
    }

    func speak(_ text: String, for senseType: SenseType) async {
        // Tier 1: User-recorded custom prompt
        if customPromptStorage.hasCustomPrompt(for: senseType) {
            let url = customPromptStorage.fileURL(for: senseType)
            if await playAudio(from: url) { return }
        }

        // Tier 2: Bundled AI-voiced prompt (e.g. default_see.mp3)
        if let bundledURL = senseType.bundledPromptURL {
            if await playAudio(from: bundledURL) { return }
        }

        // Tier 3: Fall back to TTS
        await speak(text)
    }

    private func playAudio(from url: URL) async -> Bool {
        isSpeaking = true
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default)
            try session.setActive(true)

            let player = try AVAudioPlayer(contentsOf: url)
            player.delegate = self
            self.audioPlayer = player

            await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
                self.playbackContinuation = continuation
                player.play()
            }
            isSpeaking = false
            return true
        } catch {
            isSpeaking = false
            return false
        }
    }

    func stopSpeaking() {
        synthesizer.stopSpeaking(at: .immediate)
        audioPlayer?.stop()
        audioPlayer = nil
        isSpeaking = false
        speakContinuation?.resume()
        speakContinuation = nil
        playbackContinuation?.resume()
        playbackContinuation = nil
    }

    // MARK: - AVSpeechSynthesizerDelegate

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        speakContinuation?.resume()
        speakContinuation = nil
    }

    // MARK: - AVAudioPlayerDelegate

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        playbackContinuation?.resume()
        playbackContinuation = nil
    }
}
