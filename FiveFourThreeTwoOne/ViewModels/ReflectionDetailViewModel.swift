import SwiftUI
import SwiftData

@MainActor
@Observable
final class ReflectionDetailViewModel {
    private let audioPlayer: any AudioPlaying

    let reflection: Reflection
    var currentlyPlayingEntryID: SenseEntry?
    var playbackState: PlaybackState = .idle

    var sortedEntries: [SenseEntry] {
        reflection.entries.sorted { $0.senseType.stepIndex < $1.senseType.stepIndex }
    }

    init(reflection: Reflection, audioPlayer: any AudioPlaying) {
        self.reflection = reflection
        self.audioPlayer = audioPlayer
    }

    func playAudio(for entry: SenseEntry) throws {
        guard let url = entry.audioFileURL else { return }
        try audioPlayer.play(url: url)
        currentlyPlayingEntryID = entry
    }

    func stopAudio() {
        audioPlayer.stop()
        currentlyPlayingEntryID = nil
    }
}
