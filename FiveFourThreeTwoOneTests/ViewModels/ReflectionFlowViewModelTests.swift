import Testing
import SwiftData
@testable import FiveFourThreeTwoOne

@MainActor
struct ReflectionFlowViewModelTests {
    private func makeSUT() throws -> (ReflectionFlowViewModel, MockVoiceGuide, ModelContext) {
        let container = try TestModelContainer.create()
        let context = ModelContext(container)
        let voiceGuide = MockVoiceGuide()
        let vm = ReflectionFlowViewModel(modelContext: context, voiceGuide: voiceGuide)
        return (vm, voiceGuide, context)
    }

    @Test func initCreatesReflectionInContext() throws {
        let (_, _, context) = try makeSUT()
        let descriptor = FetchDescriptor<Reflection>()
        let reflections = try context.fetch(descriptor)
        #expect(reflections.count == 1)
    }

    @Test func currentSenseTypeAtStepZeroIsSee() throws {
        let (vm, _, _) = try makeSUT()
        #expect(vm.currentSenseType == .see)
    }

    @Test func totalStepsIsFive() throws {
        let (vm, _, _) = try makeSUT()
        #expect(vm.totalSteps == 5)
    }

    @Test func progressAtStepZeroIsZero() throws {
        let (vm, _, _) = try makeSUT()
        #expect(vm.progress == 0.0)
    }

    @Test func commitEntryAdvancesStep() throws {
        let (vm, _, _) = try makeSUT()
        let entry = SenseEntry(senseType: .see, transcribedText: "sky")
        vm.commitEntry(entry)
        #expect(vm.currentStepIndex == 1)
        #expect(vm.currentSenseType == .touch)
        #expect(vm.isFlowComplete == false)
    }

    @Test func commitEntryAtLastStepMarksComplete() throws {
        let (vm, _, _) = try makeSUT()

        for senseType in SenseType.orderedCases {
            let entry = SenseEntry(senseType: senseType, transcribedText: "test")
            vm.commitEntry(entry)
        }

        #expect(vm.isFlowComplete == true)
        #expect(vm.reflection.isComplete == true)
        #expect(!vm.reflection.title.isEmpty)
    }

    @Test func cancelFlowDeletesReflection() throws {
        let (vm, _, context) = try makeSUT()
        vm.cancelFlow()

        let descriptor = FetchDescriptor<Reflection>()
        let reflections = try context.fetch(descriptor)
        #expect(reflections.isEmpty)
    }

    @Test func speakGuidanceCallsVoiceGuide() async throws {
        let (vm, voiceGuide, _) = try makeSUT()
        await vm.speakGuidance()
        #expect(voiceGuide.speakCallCount == 1)
        #expect(voiceGuide.lastSpokenText == SenseType.see.guidancePrompt)
    }

    @Test func progressIncreasesWithSteps() throws {
        let (vm, _, _) = try makeSUT()
        #expect(vm.progress == 0.0)

        let entry = SenseEntry(senseType: .see, transcribedText: "test")
        vm.commitEntry(entry)
        #expect(vm.progress == 0.2)
    }

    @Test func reflectionEntriesAccumulateAcrossSteps() throws {
        let (vm, _, _) = try makeSUT()

        let entry1 = SenseEntry(senseType: .see, transcribedText: "sky")
        vm.commitEntry(entry1)

        let entry2 = SenseEntry(senseType: .touch, transcribedText: "desk")
        vm.commitEntry(entry2)

        #expect(vm.reflection.entries.count == 2)
    }
}
