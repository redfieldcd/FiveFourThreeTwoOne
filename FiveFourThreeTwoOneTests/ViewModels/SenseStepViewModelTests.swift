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
        #expect(vm.confirmedItemCount == 0)
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

    // MARK: - Tap-to-Confirm Tests

    @Test func confirmItemIncrementsCount() {
        let (vm, _, _) = makeSUT(senseType: .see) // 5 items
        #expect(vm.confirmedItemCount == 0)

        let result = vm.confirmItem()
        #expect(result == true)
        #expect(vm.confirmedItemCount == 1)
    }

    @Test func confirmItemStopsAtMax() {
        let (vm, _, _) = makeSUT(senseType: .taste) // 1 item
        #expect(vm.confirmItem() == true)
        #expect(vm.confirmedItemCount == 1)

        // Should not go beyond max
        #expect(vm.confirmItem() == false)
        #expect(vm.confirmedItemCount == 1)
    }

    @Test func detectedItemCountCapsAtExpected() {
        let (vm, _, _) = makeSUT(senseType: .smell) // 2 items
        vm.confirmItem()
        vm.confirmItem()
        #expect(vm.detectedItemCount == 2)

        // Can't exceed expected
        vm.confirmItem()
        #expect(vm.detectedItemCount == 2)
    }

    @Test func allItemsConfirmedReturnsTrueWhenComplete() {
        let (vm, _, _) = makeSUT(senseType: .taste) // 1 item
        #expect(vm.allItemsConfirmed == false)

        vm.confirmItem()
        #expect(vm.allItemsConfirmed == true)
    }

    @Test func allItemsConfirmedForFiveItems() {
        let (vm, _, _) = makeSUT(senseType: .see) // 5 items
        for _ in 0..<5 {
            #expect(vm.allItemsConfirmed == false)
            vm.confirmItem()
        }
        #expect(vm.allItemsConfirmed == true)
    }

    @Test func detectedItemCountInManualModeUsesTextParsing() {
        let (vm, _, _) = makeSUT(senseType: .see) // 5 items
        vm.inputMode = .manual
        vm.manualText = "dog, cat, tree"
        #expect(vm.detectedItemCount == 3)
    }

    @Test func detectedItemCountInVoiceModeUsesConfirmedCount() {
        let (vm, _, _) = makeSUT(senseType: .hear) // 3 items
        vm.inputMode = .voice
        vm.confirmItem()
        vm.confirmItem()
        #expect(vm.detectedItemCount == 2)
    }

    @Test func expectedItemCountMatchesSenseType() {
        let (vm5, _, _) = makeSUT(senseType: .see)
        #expect(vm5.expectedItemCount == 5)

        let (vm1, _, _) = makeSUT(senseType: .taste)
        #expect(vm1.expectedItemCount == 1)
    }
}
