import Foundation
@testable import FiveFourThreeTwoOne

final class MockAudioPlayer: AudioPlaying {
    var playbackState: PlaybackState = .idle
    var playCallCount = 0
    var pauseCallCount = 0
    var stopCallCount = 0
    var lastPlayedURL: URL?

    func play(url: URL) throws {
        playCallCount += 1
        lastPlayedURL = url
        playbackState = .playing(progress: 0.0)
    }

    func pause() {
        pauseCallCount += 1
        playbackState = .paused(progress: 0.5)
    }

    func stop() {
        stopCallCount += 1
        playbackState = .idle
    }

    func seek(to progress: Double) {
        playbackState = .playing(progress: progress)
    }
}
