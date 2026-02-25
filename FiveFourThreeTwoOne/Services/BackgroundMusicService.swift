import AVFoundation

final class BackgroundMusicService {
    static let shared = BackgroundMusicService()

    private var player: AVAudioPlayer?

    private init() {}

    func play() {
        guard player == nil || player?.isPlaying == false else { return }

        guard let url = Bundle.main.url(forResource: "Whispering_Canopy", withExtension: "mp3") else {
            return
        }

        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.ambient, mode: .default)
            try session.setActive(true)

            player = try AVAudioPlayer(contentsOf: url)
            player?.numberOfLoops = -1
            player?.volume = 0.2
            player?.play()
        } catch {
            player = nil
        }
    }

    func stop() {
        player?.stop()
        player = nil
    }
}
