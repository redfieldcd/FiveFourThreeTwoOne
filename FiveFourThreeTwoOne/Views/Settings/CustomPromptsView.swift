import SwiftUI

struct CustomPromptsView: View {
    @State private var viewModel = CustomPromptsViewModel()
    @State private var showingDeleteConfirmation = false
    @State private var senseToDelete: SenseType?

    var body: some View {
        List {
            Section {
                ForEach(SenseType.orderedCases) { senseType in
                    CustomPromptRow(
                        senseType: senseType,
                        state: viewModel.promptStates[senseType] ?? .none,
                        onRecord: { viewModel.startRecording(for: senseType) },
                        onStopRecording: { viewModel.stopRecording() },
                        onPlay: { viewModel.playPrompt(for: senseType) },
                        onStopPlayback: { viewModel.stopPlayback() },
                        onDelete: {
                            senseToDelete = senseType
                            showingDeleteConfirmation = true
                        }
                    )
                }
            } footer: {
                Text("Record a custom voice prompt for each sense. During a reflection, your recorded prompt will play instead of the default computer voice.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .alert("Delete Prompt?", isPresented: $showingDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                if let senseType = senseToDelete {
                    viewModel.deletePrompt(for: senseType)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            if let senseType = senseToDelete {
                Text("This will remove your custom \(senseType.displayName) prompt and revert to the default voice.")
            }
        }
        .alert("Error", isPresented: .init(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("OK") { viewModel.errorMessage = nil }
        } message: {
            if let error = viewModel.errorMessage {
                Text(error)
            }
        }
    }
}
