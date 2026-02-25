import Testing
@testable import FiveFourThreeTwoOne

@MainActor
struct SenseStepViewModelTests {
    private func makeSUT(senseType: SenseType = .see) -> (SenseStepViewModel, MockSpeechRecognizer, MockAudioRecorder) {
        let speechRecognizer = MockSpeechRecognizer()
        let audioRecorder = MockAudioRecorder()
        let vm = SenseStepViewModel(
            senseType: senseType,
            speechRecognizer: speechRecognizer,
            audioRecorder: audioRecorder
        )
        return (vm, speechRecognizer, audioRecorder)
    }

    @Test func initialStateIsNotRecording() {
        let (vm, _, _) = makeSUT()
        #expect(vm.isRecording == false)
        #expect(vm.transcribedText == "")
        #expect(vm.manualText == "")
        #expect(vm.inputMode == .voice)
    }

    @Test func finalTextInVoiceModeReturnsTranscription() {
        let (vm, _, _) = makeSUT()
        vm.transcribedText = "hello world"
        #expect(vm.finalText == "hello world")
    }

    @Test func finalTextInManualModeReturnsManualText() {
        let (vm, _, _) = makeSUT()
        vm.inputMode = .manual
        vm.manualText = "typed text"
        vm.transcribedText = "should not use this"
        #expect(vm.finalText == "typed text")
    }

    @Test func createManualEntryUsesManualText() {
        let (vm, _, _) = makeSUT(senseType: .hear)
        vm.manualText = "birds singing"
        let entry = vm.createManualEntry()
        #expect(entry.transcribedText == "birds singing")
        #expect(entry.senseType == .hear)
        #expect(entry.audioFileName == nil)
    }

    @Test func stopRecordingReturnsSenseEntry() async {
        let (vm, speechRecognizer, audioRecorder) = makeSUT(senseType: .touch)
        speechRecognizer.transcriptionResults = ["smooth surface"]

        let entry = await vm.stopRecording()
        #expect(entry.senseType == .touch)
        #expect(speechRecognizer.stopTranscribingCallCount == 1)
        #expect(audioRecorder.stopRecordingCallCount == 1)
        #expect(vm.isRecording == false)
    }

    @Test func senseTypeMatchesInit() {
        let (vm, _, _) = makeSUT(senseType: .smell)
        #expect(vm.senseType == .smell)
    }
}
