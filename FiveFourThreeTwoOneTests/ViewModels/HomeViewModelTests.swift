import Testing
import Foundation
import SwiftData
@testable import FiveFourThreeTwoOne

@MainActor
struct HomeViewModelTests {
    private func makeSUT() throws -> (HomeViewModel, ModelContext) {
        let container = try TestModelContainer.create()
        let context = ModelContext(container)
        let vm = HomeViewModel(modelContext: context)
        return (vm, context)
    }

    @Test func fetchReflectionsReturnsOnlyComplete() throws {
        let (vm, context) = try makeSUT()

        let complete = Reflection(title: "Done", isComplete: true)
        let incomplete = Reflection(title: "WIP", isComplete: false)
        context.insert(complete)
        context.insert(incomplete)
        try context.save()

        vm.fetchReflections()
        #expect(vm.reflections.count == 1)
        #expect(vm.reflections[0].title == "Done")
    }

    @Test func fetchReflectionsSortedByDateDescending() throws {
        let (vm, context) = try makeSUT()

        let older = Reflection(title: "Older", createdAt: Date.now.addingTimeInterval(-3600), isComplete: true)
        let newer = Reflection(title: "Newer", createdAt: Date.now, isComplete: true)
        context.insert(older)
        context.insert(newer)
        try context.save()

        vm.fetchReflections()
        #expect(vm.reflections.count == 2)
        #expect(vm.reflections[0].title == "Newer")
        #expect(vm.reflections[1].title == "Older")
    }

    @Test func deleteReflectionRemovesFromContext() throws {
        let (vm, context) = try makeSUT()

        let reflection = Reflection(title: "To Delete", isComplete: true)
        context.insert(reflection)
        try context.save()

        vm.fetchReflections()
        #expect(vm.reflections.count == 1)

        vm.deleteReflection(reflection)
        #expect(vm.reflections.isEmpty)

        let descriptor = FetchDescriptor<Reflection>()
        let remaining = try context.fetch(descriptor)
        #expect(remaining.isEmpty)
    }

    @Test func fetchReflectionsWithNoDataReturnsEmpty() throws {
        let (vm, _) = try makeSUT()
        vm.fetchReflections()
        #expect(vm.reflections.isEmpty)
    }
}
