import SwiftUI

struct FlowCompletionView: View {
    let reflection: Reflection
    let onSave: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                completionHeader

                journalContent

                saveButton
            }
            .padding()
        }
    }

    private var completionHeader: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 56))
                .foregroundStyle(.green)

            Text("Reflection Complete")
                .font(.title2)
                .fontWeight(.bold)

            Text("Here's your journal entry")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var journalContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(reflection.entries.sorted(by: { $0.senseType.stepIndex < $1.senseType.stepIndex })) { entry in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        SenseIconView(senseType: entry.senseType, size: 32)
                        Text("\(entry.senseType.count) thing(s) I could \(entry.senseType.displayName.lowercased())")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }

                    Text(entry.transcribedText)
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .padding(.leading, 40)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
        )
    }

    private var saveButton: some View {
        Button(action: onSave) {
            Text("Save & Close")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.accentColor)
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .padding(.top, 8)
    }
}
