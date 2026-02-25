import SwiftUI

struct AudioPlayerView: View {
    let isPlaying: Bool
    let senseType: SenseType
    let onPlay: () -> Void
    let onStop: () -> Void

    var body: some View {
        Button {
            if isPlaying {
                onStop()
            } else {
                onPlay()
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: isPlaying ? "stop.circle.fill" : "play.circle.fill")
                    .font(.title3)
                Text(isPlaying ? "Stop" : "Play recording")
                    .font(.caption)
            }
            .foregroundStyle(Color.senseColor(for: senseType))
        }
        .frame(minWidth: 44, minHeight: 44)
        .accessibilityLabel(isPlaying ? "Stop audio" : "Play audio for \(senseType.displayName)")
    }
}
