import SwiftUI

struct SenseStepView: View {
    @Bindable var viewModel: SenseStepViewModel
    let onComplete: (SenseEntry) -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var previousItemCount = 0

    private let feedback = FeedbackService.shared

    var body: some View {
        VStack(spacing: 24) {
            senseHeader

            ItemCounterView(
                senseType: viewModel.senseType,
                filledCount: viewModel.detectedItemCount,
                totalCount: viewModel.expectedItemCount
            )

            Picker("Input Mode", selection: $viewModel.inputMode) {
                Text("Voice").tag(SenseStepViewModel.InputMode.voice)
                Text("Type").tag(SenseStepViewModel.InputMode.manual)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)

            if viewModel.inputMode == .voice {
                voiceInputSection
            } else {
                manualInputSection
            }

            Spacer()

            nextButton
        }
        .padding()
        .onChange(of: viewModel.detectedItemCount) { oldValue, newValue in
            guard newValue > oldValue else { return }
            if newValue >= viewModel.expectedItemCount {
                feedback.playAllItemsComplete()
            }
            previousItemCount = newValue
        }
    }

    private var senseHeader: some View {
        VStack(spacing: 12) {
            SenseIconView(senseType: viewModel.senseType, size: 72)

            Text("Name \(viewModel.senseType.count) thing(s) you can \(viewModel.senseType.displayName.lowercased())")
                .font(.title3)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }

    private var voiceInputSection: some View {
        VStack(spacing: 20) {
            TranscriptionView(
                text: viewModel.transcribedText,
                isRecording: viewModel.isRecording
            )

            PulsingRecordButton(isRecording: viewModel.isRecording) {
                Task {
                    if viewModel.isRecording {
                        feedback.playRecordStop()
                        let entry = await viewModel.stopRecording()
                        onComplete(entry)
                    } else {
                        feedback.playRecordStart()
                        try? await viewModel.startRecording()
                    }
                }
            }
        }
    }

    private var manualInputSection: some View {
        VStack(spacing: 16) {
            TextField(
                "Describe what you \(viewModel.senseType.displayName.lowercased())...",
                text: $viewModel.manualText,
                axis: .vertical
            )
            .lineLimit(3...8)
            .textFieldStyle(.roundedBorder)
            .padding(.horizontal)
        }
    }

    private var nextButton: some View {
        Group {
            if viewModel.inputMode == .manual && !viewModel.manualText.isEmpty {
                Button {
                    feedback.playButtonTap()
                    let entry = viewModel.createManualEntry()
                    onComplete(entry)
                } label: {
                    Text("Next")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .padding(.horizontal)
            }
        }
    }
}
