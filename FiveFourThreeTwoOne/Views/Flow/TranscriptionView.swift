import SwiftUI

struct TranscriptionView: View {
    let text: String
    let isRecording: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                if isRecording {
                    Circle()
                        .fill(.red)
                        .frame(width: 8, height: 8)
                    Text("Listening...")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            if text.isEmpty && isRecording {
                Text("Start speaking...")
                    .font(.body)
                    .foregroundStyle(.tertiary)
                    .italic()
            } else if !text.isEmpty {
                Text(text)
                    .font(.body)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 80, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(text.isEmpty ? "Transcription area" : "Transcription: \(text)")
    }
}
