import SwiftUI
import SwiftData

struct ReflectionFlowView: View {
    @Environment(AppSettings.self) private var appSettings
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var flowVM: ReflectionFlowViewModel?
    @State private var stepVM: SenseStepViewModel?
    @State private var showCountdown = true

    private let speechRecognizer: any SpeechRecognizing
    private let audioRecorder: any AudioRecording
    private let voiceGuide: any VoiceGuiding

    init(speechRecognizer: any SpeechRecognizing = SpeechRecognitionService(),
         audioRecorder: any AudioRecording = AudioRecordingService(),
         voiceGuide: any VoiceGuiding = VoiceGuidanceService()) {
        self.speechRecognizer = speechRecognizer
        self.audioRecorder = audioRecorder
        self.voiceGuide = voiceGuide
    }

    var body: some View {
        ZStack {
            appSettings.backgroundColor
                .ignoresSafeArea()

        Group {
            if showCountdown {
                BreathingCountdownView {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        showCountdown = false
                    }
                }
            } else if let flowVM {
                if flowVM.isFlowComplete {
                    FlowCompletionView(reflection: flowVM.reflection) {
                        dismiss()
                    }
                } else {
                    flowContent(flowVM)
                }
            } else {
                ProgressView("Preparing...")
            }
        }
        } // ZStack
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    flowVM?.cancelFlow()
                    dismiss()
                }
            }
        }
        .onChange(of: showCountdown) { _, newValue in
            if !newValue && flowVM == nil {
                let vm = ReflectionFlowViewModel(modelContext: modelContext, voiceGuide: voiceGuide)
                flowVM = vm
                createStepVM(for: vm.currentSenseType)
                Task { await vm.speakGuidance() }
            }
        }
    }

    @ViewBuilder
    private func flowContent(_ flowVM: ReflectionFlowViewModel) -> some View {
        VStack(spacing: 0) {
            ProgressStepIndicator(
                currentStep: flowVM.currentStepIndex,
                totalSteps: flowVM.totalSteps
            )
            .padding(.top, 16)
            .padding(.bottom, 24)

            if let stepVM {
                SenseStepView(viewModel: stepVM) { entry in
                    flowVM.commitEntry(entry)
                    if !flowVM.isFlowComplete {
                        createStepVM(for: flowVM.currentSenseType)
                        Task { await flowVM.speakGuidance() }
                    }
                }
                .id(flowVM.currentStepIndex)
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
                .animation(.easeInOut(duration: 0.3), value: flowVM.currentStepIndex)
            }
        }
    }

    private func createStepVM(for senseType: SenseType) {
        stepVM = SenseStepViewModel(
            senseType: senseType,
            speechRecognizer: speechRecognizer,
            audioRecorder: audioRecorder
        )
    }
}
