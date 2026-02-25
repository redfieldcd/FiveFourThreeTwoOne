import SwiftData

struct PreviewSampleData {
    static var container: ModelContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(
            for: Reflection.self, SenseEntry.self,
            configurations: config
        )

        let context = ModelContext(container)

        let reflection = Reflection(
            title: "Morning Reflection",
            createdAt: .now.addingTimeInterval(-3600),
            isComplete: true,
            entries: [
                SenseEntry(senseType: .see, transcribedText: "Blue sky, green trees, my coffee mug, the cat, sunlight on the wall"),
                SenseEntry(senseType: .touch, transcribedText: "Warm cup in my hands, soft blanket, cool air, smooth table"),
                SenseEntry(senseType: .hear, transcribedText: "Birds chirping, distant traffic, the fridge humming"),
                SenseEntry(senseType: .smell, transcribedText: "Fresh coffee, morning air"),
                SenseEntry(senseType: .taste, transcribedText: "Coffee with a hint of cinnamon"),
            ]
        )

        let reflection2 = Reflection(
            title: "Evening Wind Down",
            createdAt: .now.addingTimeInterval(-86400),
            isComplete: true,
            entries: [
                SenseEntry(senseType: .see, transcribedText: "Sunset colors, lamp glow, book on the shelf, plants, dimming sky"),
                SenseEntry(senseType: .touch, transcribedText: "Soft pillow, warm socks, phone in hand, couch cushion"),
                SenseEntry(senseType: .hear, transcribedText: "Music playing, wind outside, water boiling"),
                SenseEntry(senseType: .smell, transcribedText: "Lavender candle, dinner cooking"),
                SenseEntry(senseType: .taste, transcribedText: "Herbal tea"),
            ]
        )

        context.insert(reflection)
        context.insert(reflection2)
        try? context.save()

        return container
    }
}
