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
    /// Item count from speech pause detection (voice mode).
    var voiceItemCount: Int = 0

    enum InputMode {
        case voice
        case manual
    }

    var finalText: String {
        inputMode == .voice ? transcribedText : manualText
    }

    /// Number of items the user has mentioned so far, capped at the expected count.
    var detectedItemCount: Int {
        if inputMode == .voice {
            return min(voiceItemCount, senseType.count)
        } else {
            return min(Self.countItems(in: manualText), senseType.count)
        }
    }

    /// Total items expected for this sense step.
    var expectedItemCount: Int { senseType.count }

    // MARK: - Item Counting (for manual text input)

    /// Delegates to the shared `ItemCountingEngine` so that manual and voice
    /// input modes use identical text-parsing logic.
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

        // Listen to both streams concurrently
        await withTaskGroup(of: Void.self) { group in
            group.addTask { [weak self] in
                guard let self else { return }
                for await partial in self.speechRecognizer.transcriptionStream {
                    await MainActor.run { self.transcribedText = partial }
                }
            }
            group.addTask { [weak self] in
                guard let self else { return }
                for await count in self.speechRecognizer.itemCountStream {
                    await MainActor.run { self.voiceItemCount = count }
                }
            }
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
