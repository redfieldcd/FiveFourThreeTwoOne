import SwiftUI

struct CustomPromptRow: View {
    let senseType: SenseType
    let state: CustomPromptsViewModel.PromptState
    let onRecord: () -> Void
    let onStopRecording: () -> Void
    let onPlay: () -> Void
    let onStopPlayback: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            SenseIconView(senseType: senseType, size: 40)

            VStack(alignment: .leading, spacing: 4) {
                Text(senseType.displayName)
                    .font(.headline)

                Text(statusText)
                    .font(.caption)
                    .foregroundStyle(statusColor)
            }

            Spacer()

            actionButtons
        }
        .padding(.vertical, 4)
    }

    private var statusText: String {
        switch state {
        case .none: return "Using default voice"
        case .hasRecording: return "Custom prompt recorded"
        case .recording: return "Recording..."
        case .playing: return "Playing..."
        }
    }

    private var statusColor: Color {
        switch state {
        case .none: return .secondary
        case .hasRecording: return .green
        case .recording: return .red
        case .playing: return .accentColor
        }
    }

    @ViewBuilder
    private var actionButtons: some View {
        switch state {
        case .none:
            Button(action: onRecord) {
                Image(systemName: "mic.circle.fill")
                    .font(.title2)
                    .foregroundStyle(Color.accentColor)
            }
            .accessibilityLabel("Record custom prompt for \(senseType.displayName)")

        case .hasRecording:
            HStack(spacing: 12) {
                Button(action: onPlay) {
                    Image(systemName: "play.circle.fill")
                        .font(.title2)
                        .foregroundStyle(Color.accentColor)
                }
                .accessibilityLabel("Play custom prompt")

                Button(action: onRecord) {
                    Image(systemName: "mic.circle")
                        .font(.title2)
                        .foregroundStyle(Color.accentColor)
                }
                .accessibilityLabel("Re-record prompt")

                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.title3)
                        .foregroundStyle(.red)
                }
                .accessibilityLabel("Delete custom prompt")
            }

        case .recording:
            Button(action: onStopRecording) {
                Image(systemName: "stop.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.red)
                    .symbolEffect(.pulse)
            }
            .accessibilityLabel("Stop recording")

        case .playing:
            Button(action: onStopPlayback) {
                Image(systemName: "stop.circle.fill")
                    .font(.title2)
                    .foregroundStyle(Color.accentColor)
            }
            .accessibilityLabel("Stop playback")
        }
    }
}
