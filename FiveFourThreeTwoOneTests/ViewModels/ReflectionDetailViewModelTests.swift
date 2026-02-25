import Testing
@testable import FiveFourThreeTwoOne

@MainActor
struct ReflectionDetailViewModelTests {
    private func makeSUT() -> (ReflectionDetailViewModel, MockAudioPlayer, Reflection) {
        let entries = [
            SenseEntry(senseType: .taste, transcribedText: "mint"),
            SenseEntry(senseType: .see, transcribedText: "sky"),
            SenseEntry(senseType: .hear, transcribedText: "music"),
        ]
        let reflection = Reflection(title: "Test", entries: entries)
        let player = MockAudioPlayer()
        let vm = ReflectionDetailViewModel(reflection: reflection, audioPlayer: player)
        return (vm, player, reflection)
    }

    @Test func sortedEntriesOrderedByStepIndex() {
        let (vm, _, _) = makeSUT()
        let sorted = vm.sortedEntries
        #expect(sorted[0].senseType == .see)
        #expect(sorted[1].senseType == .hear)
        #expect(sorted[2].senseType == .taste)
    }

    @Test func playAudioCallsPlayerWithCorrectURL() throws {
        let entry = SenseEntry(senseType: .see, transcribedText: "test", audioFileName: "test.m4a")
        let reflection = Reflection(entries: [entry])
        let player = MockAudioPlayer()
        let vm = ReflectionDetailViewModel(reflection: reflection, audioPlayer: player)

        try vm.playAudio(for: entry)
        #expect(player.playCallCount == 1)
        #expect(player.lastPlayedURL?.lastPathComponent == "test.m4a")
    }

    @Test func playAudioDoesNothingWhenNoAudioFile() throws {
        let entry = SenseEntry(senseType: .see, transcribedText: "test")
        let reflection = Reflection(entries: [entry])
        let player = MockAudioPlayer()
        let vm = ReflectionDetailViewModel(reflection: reflection, audioPlayer: player)

        try vm.playAudio(for: entry)
        #expect(player.playCallCount == 0)
    }

    @Test func stopAudioStopsPlayer() {
        let (vm, player, _) = makeSUT()
        vm.stopAudio()
        #expect(player.stopCallCount == 1)
        #expect(vm.currentlyPlayingEntryID == nil)
    }
}
