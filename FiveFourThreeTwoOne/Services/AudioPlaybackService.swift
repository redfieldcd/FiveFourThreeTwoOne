import AVFoundation

final class AudioPlaybackService: NSObject, AudioPlaying, AVAudioPlayerDelegate {
    private var audioPlayer: AVAudioPlayer?
    private var progressTimer: Timer?

    private(set) var playbackState: PlaybackState = .idle

    func play(url: URL) throws {
        stop()

        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playback, mode: .default)
        try session.setActive(true)

        audioPlayer = try AVAudioPlayer(contentsOf: url)
        audioPlayer?.delegate = self
        audioPlayer?.play()

        playbackState = .playing(progress: 0.0)
        startProgressTimer()
    }

    func pause() {
        audioPlayer?.pause()
        stopProgressTimer()
        let progress = currentProgress()
        playbackState = .paused(progress: progress)
    }

    func stop() {
        audioPlayer?.stop()
        audioPlayer = nil
        stopProgressTimer()
        playbackState = .idle
    }

    func seek(to progress: Double) {
        guard let player = audioPlayer else { return }
        let time = player.duration * progress
        player.currentTime = time
        playbackState = .playing(progress: progress)
    }

    // MARK: - AVAudioPlayerDelegate

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        stopProgressTimer()
        playbackState = .finished
    }

    // MARK: - Private

    private func currentProgress() -> Double {
        guard let player = audioPlayer, player.duration > 0 else { return 0.0 }
        return player.currentTime / player.duration
    }

    private func startProgressTimer() {
        progressTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self else { return }
            let progress = self.currentProgress()
            self.playbackState = .playing(progress: progress)
        }
    }

    private func stopProgressTimer() {
        progressTimer?.invalidate()
        progressTimer = nil
    }
}
