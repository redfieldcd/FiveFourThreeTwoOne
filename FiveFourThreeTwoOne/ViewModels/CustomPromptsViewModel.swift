import AVFoundation

@MainActor
@Observable
final class CustomPromptsViewModel {
    enum PromptState {
        case none
        case hasRecording
        case recording
        case playing
    }

    private let audioRecorder: any AudioRecording
    private let storage: any CustomPromptStoring
    private var audioPlayer: AVAudioPlayer?
    private var playbackTimer: Timer?

    var promptStates: [SenseType: PromptState] = [:]
    var activeSenseType: SenseType?
    var errorMessage: String?

    init(audioRecorder: any AudioRecording = AudioRecordingService(),
         storage: any CustomPromptStoring = CustomPromptStorage()) {
        self.audioRecorder = audioRecorder
        self.storage = storage
        loadStates()
    }

    func loadStates() {
        for senseType in SenseType.allCases {
            promptStates[senseType] = storage.hasCustomPrompt(for: senseType) ? .hasRecording : .none
        }
    }

    func startRecording(for senseType: SenseType) {
        stopCurrentAction()

        do {
            try storage.ensureDirectoryExists()
            let url = storage.fileURL(for: senseType)
            // Remove existing file before re-recording
            try? storage.deleteCustomPrompt(for: senseType)
            try audioRecorder.startRecording(to: url)
            activeSenseType = senseType
            promptStates[senseType] = .recording
        } catch {
            errorMessage = "Could not start recording: \(error.localizedDescription)"
        }
    }

    func stopRecording() {
        guard let senseType = activeSenseType, promptStates[senseType] == .recording else { return }
        _ = audioRecorder.stopRecording()
        promptStates[senseType] = .hasRecording
        activeSenseType = nil
    }

    func playPrompt(for senseType: SenseType) {
        stopCurrentAction()

        let url = storage.fileURL(for: senseType)
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default)
            try session.setActive(true)

            let player = try AVAudioPlayer(contentsOf: url)
            self.audioPlayer = player
            activeSenseType = senseType
            promptStates[senseType] = .playing
            player.play()

            playbackTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] timer in
                Task { @MainActor in
                    guard let self else { timer.invalidate(); return }
                    if self.audioPlayer?.isPlaying != true {
                        timer.invalidate()
                        self.playbackTimer = nil
                        self.promptStates[senseType] = .hasRecording
                        self.activeSenseType = nil
                        self.audioPlayer = nil
                    }
                }
            }
        } catch {
            errorMessage = "Could not play recording: \(error.localizedDescription)"
        }
    }

    func stopPlayback() {
        guard let senseType = activeSenseType, promptStates[senseType] == .playing else { return }
        audioPlayer?.stop()
        audioPlayer = nil
        playbackTimer?.invalidate()
        playbackTimer = nil
        promptStates[senseType] = .hasRecording
        activeSenseType = nil
    }

    func deletePrompt(for senseType: SenseType) {
        if activeSenseType == senseType {
            stopCurrentAction()
        }
        do {
            try storage.deleteCustomPrompt(for: senseType)
            promptStates[senseType] = .none
        } catch {
            errorMessage = "Could not delete recording: \(error.localizedDescription)"
        }
    }

    private func stopCurrentAction() {
        guard let active = activeSenseType else { return }
        switch promptStates[active] {
        case .recording:
            _ = audioRecorder.stopRecording()
            // If we were recording a new file, check if it exists now
            promptStates[active] = storage.hasCustomPrompt(for: active) ? .hasRecording : .none
        case .playing:
            audioPlayer?.stop()
            audioPlayer = nil
            playbackTimer?.invalidate()
            playbackTimer = nil
            promptStates[active] = .hasRecording
        default:
            break
        }
        activeSenseType = nil
    }
}
