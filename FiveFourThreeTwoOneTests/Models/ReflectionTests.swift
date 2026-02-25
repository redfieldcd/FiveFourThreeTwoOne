import Testing
import SwiftData
@testable import FiveFourThreeTwoOne

struct ReflectionTests {
    @Test func initDefaults() {
        let reflection = Reflection()
        #expect(reflection.title == "")
        #expect(reflection.isComplete == false)
        #expect(reflection.entries.isEmpty)
    }

    @Test func journalTextWithNoEntries() {
        let reflection = Reflection()
        #expect(reflection.journalText == "")
    }

    @Test func journalTextWithOneEntry() {
        let entry = SenseEntry(senseType: .see, transcribedText: "blue sky, green trees")
        let reflection = Reflection(entries: [entry])
        let journal = reflection.journalText
        #expect(journal.contains("5 thing(s) I could see:"))
        #expect(journal.contains("blue sky, green trees"))
    }

    @Test func journalTextWithMultipleEntriesSortedByStepIndex() {
        let entries = [
            SenseEntry(senseType: .taste, transcribedText: "mint"),
            SenseEntry(senseType: .see, transcribedText: "sky"),
            SenseEntry(senseType: .hear, transcribedText: "music"),
        ]
        let reflection = Reflection(entries: entries)
        let journal = reflection.journalText

        let seeRange = journal.range(of: "see:")
        let hearRange = journal.range(of: "hear:")
        let tasteRange = journal.range(of: "taste:")

        #expect(seeRange != nil)
        #expect(hearRange != nil)
        #expect(tasteRange != nil)
        #expect(seeRange!.lowerBound < hearRange!.lowerBound)
        #expect(hearRange!.lowerBound < tasteRange!.lowerBound)
    }

    @Test func isCompleteCanBeSet() {
        let reflection = Reflection()
        reflection.isComplete = true
        #expect(reflection.isComplete == true)
    }

    @Test func titleCanBeSet() {
        let reflection = Reflection(title: "Morning Reflection")
        #expect(reflection.title == "Morning Reflection")
    }

    @Test func persistenceWithSwiftData() throws {
        let container = try TestModelContainer.create()
        let context = ModelContext(container)

        let reflection = Reflection(title: "Test")
        let entry = SenseEntry(senseType: .see, transcribedText: "clouds")
        reflection.entries.append(entry)

        context.insert(reflection)
        try context.save()

        let descriptor = FetchDescriptor<Reflection>()
        let fetched = try context.fetch(descriptor)
        #expect(fetched.count == 1)
        #expect(fetched[0].title == "Test")
        #expect(fetched[0].entries.count == 1)
        #expect(fetched[0].entries[0].transcribedText == "clouds")
    }

    @Test func cascadeDeleteRemovesEntries() throws {
        let container = try TestModelContainer.create()
        let context = ModelContext(container)

        let reflection = Reflection(title: "To Delete")
        let entry = SenseEntry(senseType: .hear, transcribedText: "wind")
        reflection.entries.append(entry)

        context.insert(reflection)
        try context.save()

        context.delete(reflection)
        try context.save()

        let reflections = try context.fetch(FetchDescriptor<Reflection>())
        let entries = try context.fetch(FetchDescriptor<SenseEntry>())
        #expect(reflections.isEmpty)
        #expect(entries.isEmpty)
    }
}
