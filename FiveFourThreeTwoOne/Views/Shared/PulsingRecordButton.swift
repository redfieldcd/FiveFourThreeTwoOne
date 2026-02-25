import SwiftUI

struct PulsingRecordButton: View {
    let isRecording: Bool
    let action: () -> Void

    @State private var isPulsing = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Button(action: action) {
            ZStack {
                if isRecording && !reduceMotion {
                    Circle()
                        .fill(Color.red.opacity(0.3))
                        .frame(width: 80, height: 80)
                        .scaleEffect(isPulsing ? 1.3 : 1.0)
                        .animation(
                            .easeInOut(duration: 1.0).repeatForever(autoreverses: true),
                            value: isPulsing
                        )
                }

                Circle()
                    .fill(isRecording ? Color.red : Color.accentColor)
                    .frame(width: 64, height: 64)

                Image(systemName: isRecording ? "stop.fill" : "mic.fill")
                    .font(.title2)
                    .foregroundStyle(.white)
            }
        }
        .frame(minWidth: 44, minHeight: 44)
        .accessibilityLabel(isRecording ? "Stop recording" : "Start recording")
        .accessibilityHint("Double tap to \(isRecording ? "stop" : "start") voice recording")
        .onChange(of: isRecording) { _, newValue in
            isPulsing = newValue
        }
    }
}
