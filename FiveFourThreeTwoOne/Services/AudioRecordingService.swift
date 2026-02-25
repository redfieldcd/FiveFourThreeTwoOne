import AVFoundation

final class AudioRecordingService: AudioRecording {
    private var audioRecorder: AVAudioRecorder?
    private var recordingURL: URL?

    var isRecording: Bool {
        audioRecorder?.isRecording ?? false
    }

    func startRecording(to fileURL: URL) throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
        try session.setActive(true)

        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        let dir = fileURL.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)

        audioRecorder = try AVAudioRecorder(url: fileURL, settings: settings)
        audioRecorder?.record()
        recordingURL = fileURL
    }

    func stopRecording() -> URL? {
        audioRecorder?.stop()
        let url = recordingURL
        audioRecorder = nil
        recordingURL = nil
        return url
    }
}
