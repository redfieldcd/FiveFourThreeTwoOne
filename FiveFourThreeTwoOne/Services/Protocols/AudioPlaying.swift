import Foundation

enum PlaybackState: Equatable {
    case idle
    case playing(progress: Double)
    case paused(progress: Double)
    case finished
}

protocol AudioPlaying: AnyObject {
    var playbackState: PlaybackState { get }

    func play(url: URL) throws
    func pause()
    func stop()
    func seek(to progress: Double)
}
