import SwiftUI

struct SenseStepView: View {
    @Bindable var viewModel: SenseStepViewModel
    let onComplete: (SenseEntry) -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var previousItemCount = 0

    /// Ripple effect state: position and trigger flag.
    @State private var ripplePosition: CGPoint = .zero
    @State private var showRipple: Bool = false
    @State private var rippleID: Int = 0

    private let feedback = FeedbackService.shared

    var body: some View {
        ZStack {
            VStack(spacing: 24) {
                senseHeader

                ItemCounterView(
                    senseType: viewModel.senseType,
                    filledCount: viewModel.detectedItemCount,
                    totalCount: viewModel.expectedItemCount
                )

                if viewModel.inputMode == .voice && viewModel.isRecording && !viewModel.allItemsConfirmed {
                    tapHint
                }

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

            // Ripple overlay
            rippleOverlay
        }
        .contentShape(Rectangle())
        .simultaneousGesture(
            SpatialTapGesture()
                .onEnded { value in
                    handleTapAnywhere(at: value.location)
                }
        )
        .onChange(of: viewModel.detectedItemCount) { oldValue, newValue in
            guard newValue > oldValue else { return }
            if newValue >= viewModel.expectedItemCount {
                feedback.playAllItemsComplete()
            }
            previousItemCount = newValue
        }
    }

    // MARK: - Tap Anywhere Handler

    private func handleTapAnywhere(at location: CGPoint) {
        // Only handle taps in voice mode while recording
        guard viewModel.inputMode == .voice,
              viewModel.isRecording,
              !viewModel.allItemsConfirmed else { return }

        if viewModel.confirmItem() {
            feedback.playBubbleFill()

            // Trigger ripple effect
            ripplePosition = location
            rippleID += 1
            showRipple = true

            // Hide ripple after animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                showRipple = false
            }
        }
    }

    // MARK: - Subviews

    private var tapHint: some View {
        Text(viewModel.detectedItemCount == 0
             ? "Tap anywhere after naming each item"
             : "\(viewModel.detectedItemCount) of \(viewModel.expectedItemCount) — tap for next")
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .animation(.easeInOut(duration: 0.2), value: viewModel.detectedItemCount)
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

    // MARK: - Ripple Effect

    private var rippleOverlay: some View {
        ZStack {
            if showRipple {
                Circle()
                    .fill(Color.senseColor(for: viewModel.senseType).opacity(0.2))
                    .frame(width: 60, height: 60)
                    .position(ripplePosition)
                    .scaleEffect(showRipple ? 3.0 : 0.5)
                    .opacity(showRipple ? 0.0 : 1.0)
                    .animation(
                        reduceMotion ? .none : .easeOut(duration: 0.6),
                        value: rippleID
                    )
                    .id(rippleID)
                    .allowsHitTesting(false)
            }
        }
        .allowsHitTesting(false)
    }
}
