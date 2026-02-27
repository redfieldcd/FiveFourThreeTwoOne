import SwiftUI

@MainActor
@Observable
final class SenseStepViewModel {
    private let speechRecognizer: any SpeechRecognizing
    private let audioRecorder: any AudioRecording
    let senseType: SenseType

    var transcribedText: String = ""
    var isRecording: Bool = false
    var manualText: String = ""
    var inputMode: InputMode = .voice

    /// Number of items the user has confirmed by tapping (voice mode).
    var confirmedItemCount: Int = 0

    enum InputMode {
        case voice
        case manual
    }

    var finalText: String {
        inputMode == .voice ? transcribedText : manualText
    }

    /// Number of items the user has confirmed so far, capped at the expected count.
    var detectedItemCount: Int {
        if inputMode == .voice {
            return min(confirmedItemCount, senseType.count)
        } else {
            return min(Self.countItems(in: manualText), senseType.count)
        }
    }

    /// Total items expected for this sense step.
    var expectedItemCount: Int { senseType.count }

    /// Whether the user has confirmed all required items.
    var allItemsConfirmed: Bool {
        detectedItemCount >= expectedItemCount
    }

    // MARK: - Item Counting (for manual text input)

    /// Delegates to the shared `ItemCountingEngine` so that manual input
    /// mode uses text-parsing logic to count items.
    static func countItems(in text: String) -> Int {
        ItemCountingEngine.countItems(in: text)
    }

    init(senseType: SenseType,
         speechRecognizer: any SpeechRecognizing,
         audioRecorder: any AudioRecording) {
        self.senseType = senseType
        self.speechRecognizer = speechRecognizer
        self.audioRecorder = audioRecorder
    }

    // MARK: - Tap-to-Confirm

    /// Called when the user taps anywhere on screen to confirm they've named an item.
    /// Returns `true` if the tap was counted (i.e., not already at max).
    @discardableResult
    func confirmItem() -> Bool {
        guard confirmedItemCount < senseType.count else { return false }
        confirmedItemCount += 1
        return true
    }

    // MARK: - Recording

    func startRecording() async throws {
        let audioDir = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Audio", isDirectory: true)
        try FileManager.default.createDirectory(at: audioDir,
            withIntermediateDirectories: true)

        let fileName = "\(UUID().uuidString).m4a"
        let fileURL = audioDir.appendingPathComponent(fileName)

        try audioRecorder.startRecording(to: fileURL)
        try speechRecognizer.startTranscribing()
        isRecording = true

        // Listen to the transcription stream
        for await partial in speechRecognizer.transcriptionStream {
            transcribedText = partial
        }
    }

    func stopRecording() async -> SenseEntry {
        let finalTranscription = await speechRecognizer.stopTranscribing()
        let audioURL = audioRecorder.stopRecording()
        isRecording = false
        transcribedText = finalTranscription

        return SenseEntry(
            senseType: senseType,
            transcribedText: finalText,
            audioFileName: audioURL?.lastPathComponent
        )
    }

    func createManualEntry() -> SenseEntry {
        SenseEntry(
            senseType: senseType,
            transcribedText: manualText,
            audioFileName: nil
        )
    }
}
