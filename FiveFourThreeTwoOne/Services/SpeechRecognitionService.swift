import Speech
import AVFoundation

final class SpeechRecognitionService: SpeechRecognizing {
    private let speechRecognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    private var streamContinuation: AsyncStream<String>.Continuation?
    private var itemCountContinuation: AsyncStream<Int>.Continuation?
    private let countingEngine = ItemCountingEngine()

    private(set) var status: SpeechRecognitionStatus = .notStarted

    var transcriptionStream: AsyncStream<String> {
        AsyncStream { continuation in
            self.streamContinuation = continuation
        }
    }

    var itemCountStream: AsyncStream<Int> {
        AsyncStream { continuation in
            self.itemCountContinuation = continuation
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
            guard let self else { return }
            if let result {
                let transcription = result.bestTranscription
                let text = transcription.formattedString
                self.streamContinuation?.yield(text)

                // Convert SFTranscriptionSegments to engine-friendly structs
                let segmentData = transcription.segments.map { seg in
                    ItemCountingEngine.Segment(
                        substring: seg.substring,
                        timestamp: seg.timestamp,
                        duration: seg.duration
                    )
                }

                if let count = self.countingEngine.process(
                    formattedString: text,
                    segments: segmentData
                ) {
                    self.itemCountContinuation?.yield(count)
                }
            }

            if error != nil || (result?.isFinal ?? false) {
                self.cleanupAudioEngine()
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
        itemCountContinuation?.finish()
        itemCountContinuation = nil
        recognitionTask = nil
        recognitionRequest = nil
        countingEngine.reset()
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
