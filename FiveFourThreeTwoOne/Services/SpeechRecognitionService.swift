import Speech
import AVFoundation

final class SpeechRecognitionService: SpeechRecognizing {
    private let speechRecognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    private var streamContinuation: AsyncStream<String>.Continuation?
    private var itemCountContinuation: AsyncStream<Int>.Continuation?

    /// Minimum pause duration (seconds) between segments to count as a new item.
    private let pauseThreshold: TimeInterval = 0.6

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
                let text = result.bestTranscription.formattedString
                self.streamContinuation?.yield(text)

                let itemCount = self.countItemsFromSegments(result.bestTranscription)
                self.itemCountContinuation?.yield(itemCount)
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
        status = .notStarted

        return finalText
    }

    // MARK: - Pause-Based Item Counting

    /// Counts distinct items by detecting pauses between speech segments and punctuation boundaries.
    private func countItemsFromSegments(_ transcription: SFTranscription) -> Int {
        let segments = transcription.segments
        guard !segments.isEmpty else { return 0 }

        // Start with 1 item (the first thing they say)
        var count = 1

        for i in 1..<segments.count {
            let prev = segments[i - 1]
            let curr = segments[i]

            // Gap between end of previous segment and start of current segment
            let prevEnd = prev.timestamp + prev.duration
            let gap = curr.timestamp - prevEnd

            // Check if there's a meaningful pause
            if gap >= pauseThreshold {
                count += 1
                continue
            }

            // Also check for punctuation-based separators in the substring
            let prevText = prev.substring.trimmingCharacters(in: .whitespacesAndNewlines)
            if prevText.hasSuffix(",") || prevText.hasSuffix(".") || prevText.hasSuffix(";") {
                count += 1
                continue
            }

            // Check for the word "and" as a separator between items
            let currText = curr.substring.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
            if currText == "and" || prevText.lowercased() == "and" {
                // "and" by itself indicates a list transition — the next real word is a new item
                // but don't double-count; "and" itself isn't an item
                if prevText.lowercased() == "and" && !currText.isEmpty && currText != "and" {
                    count += 1
                }
            }
        }

        return max(count, 1)
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
