import Speech
import AVFoundation

final class SpeechRecognitionService: SpeechRecognizing {
    private let speechRecognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    private var streamContinuation: AsyncStream<String>.Continuation?

    private(set) var status: SpeechRecognitionStatus = .notStarted

    var transcriptionStream: AsyncStream<String> {
        AsyncStream { continuation in
            self.streamContinuation = continuation
        }
    }

    init(locale: Locale = .current) {
        self.speechRecognizer = SFSpeechRecognizer(locale: locale)
    }

    func requestAuthorization() async -> Bool {
        await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { authStatus in
                continuation.resume(returning: authStatus == .authorized)
            }
        }
    }

    func startTranscribing() throws {
        guard let speechRecognizer, speechRecognizer.isAvailable else {
            status = .unavailable(reason: "Speech recognition is not available")
            throw SpeechError.unavailable
        }

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest else {
            throw SpeechError.requestCreationFailed
        }

        recognitionRequest.shouldReportPartialResults = true
        recognitionRequest.addsPunctuation = true

        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)

        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, _ in
            self?.recognitionRequest?.append(buffer)
        }

        audioEngine.prepare()
        try audioEngine.start()
        status = .recording

        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            if let result {
                let text = result.bestTranscription.formattedString
                self?.streamContinuation?.yield(text)
            }

            if error != nil || (result?.isFinal ?? false) {
                self?.cleanupAudioEngine()
            }
        }
    }

    func stopTranscribing() async -> String {
        status = .stopping

        recognitionRequest?.endAudio()
        cleanupAudioEngine()

        let finalText = await withCheckedContinuation { (continuation: CheckedContinuation<String, Never>) in
            if let task = recognitionTask {
                let currentText = task.error == nil ? "" : ""
                task.cancel()
                continuation.resume(returning: currentText)
            } else {
                continuation.resume(returning: "")
            }
        }

        streamContinuation?.finish()
        streamContinuation = nil
        recognitionTask = nil
        recognitionRequest = nil
        status = .notStarted

        return finalText
    }

    private func cleanupAudioEngine() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
    }
}

enum SpeechError: Error {
    case unavailable
    case requestCreationFailed
}
