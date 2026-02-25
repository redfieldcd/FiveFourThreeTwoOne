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

    enum InputMode {
        case voice
        case manual
    }

    var finalText: String {
        inputMode == .voice ? transcribedText : manualText
    }

    /// Number of items the user has mentioned so far, capped at the expected count.
    var detectedItemCount: Int {
        let text = inputMode == .voice ? transcribedText : manualText
        return min(Self.countItems(in: text), senseType.count)
    }

    /// Total items expected for this sense step.
    var expectedItemCount: Int { senseType.count }

    // MARK: - Item Counting

    static func countItems(in text: String) -> Int {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return 0 }

        // Split on commas, periods, newlines, and the word "and" (as separator)
        let separatorPattern = #",|\.\s|\n|(?:^|\s)and\s"#
        let segments = trimmed
            .replacingOccurrences(
                of: separatorPattern,
                with: "|||",
                options: .regularExpression,
                range: trimmed.startIndex..<trimmed.endIndex
            )
            .components(separatedBy: "|||")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        // At minimum 1 item if there's any text
        return max(segments.count, 1)
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
