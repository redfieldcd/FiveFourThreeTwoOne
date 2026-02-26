import Foundation
import Testing
@testable import FiveFourThreeTwoOne

struct ItemCountingEngineTests {

    // MARK: - Helpers

    /// Build segment data from words and the gaps between them.
    private func makeSegments(
        _ words: [String],
        gaps: [TimeInterval] = [],
        wordDuration: TimeInterval = 0.3
    ) -> [ItemCountingEngine.Segment] {
        var segments: [ItemCountingEngine.Segment] = []
        var time: TimeInterval = 0

        for (i, word) in words.enumerated() {
            segments.append(.init(substring: word, timestamp: time, duration: wordDuration))
            time += wordDuration
            if i < gaps.count {
                time += gaps[i]
            }
        }
        return segments
    }

    // MARK: - Static countItems(in:) — Text-Based Counting

    @Test func emptyStringReturnsZero() {
        #expect(ItemCountingEngine.countItems(in: "") == 0)
    }

    @Test func whitespaceOnlyReturnsZero() {
        #expect(ItemCountingEngine.countItems(in: "   \n  ") == 0)
    }

    @Test func singleWordReturnsOne() {
        #expect(ItemCountingEngine.countItems(in: "dog") == 1)
    }

    @Test func singleMultiWordItemReturnsOne() {
        #expect(ItemCountingEngine.countItems(in: "the blue sky") == 1)
    }

    @Test func commasSeparateItems() {
        #expect(ItemCountingEngine.countItems(in: "dog, cat, tree") == 3)
    }

    @Test func commasWithoutSpaces() {
        #expect(ItemCountingEngine.countItems(in: "dog,cat,tree") == 3)
    }

    @Test func periodsSeparateItems() {
        #expect(ItemCountingEngine.countItems(in: "The sky. The grass. A bird.") == 3)
    }

    @Test func semicolonsSeparateItems() {
        #expect(ItemCountingEngine.countItems(in: "a dog; a cat; a tree") == 3)
    }

    @Test func andSeparatesItems() {
        #expect(ItemCountingEngine.countItems(in: "dog and cat") == 2)
    }

    @Test func multipleAndsSeparateItems() {
        #expect(ItemCountingEngine.countItems(in: "dog and cat and tree") == 3)
    }

    @Test func commaAndAndCombined() {
        #expect(ItemCountingEngine.countItems(in: "dog, cat, and tree") == 3)
    }

    @Test func multiWordItemsWithCommas() {
        #expect(ItemCountingEngine.countItems(in: "the blue sky, a red car") == 2)
    }

    @Test func newlinesSeparateItems() {
        #expect(ItemCountingEngine.countItems(in: "dog\ncat\ntree") == 3)
    }

    @Test func fiveItemsCommaSeparated() {
        #expect(ItemCountingEngine.countItems(in: "the sky, my desk, a pen, a cup, the window") == 5)
    }

    @Test func trailingPunctuationDoesNotAddExtraItem() {
        #expect(ItemCountingEngine.countItems(in: "dog, cat,") == 2)
    }

    // MARK: - process() — Stabilization (High-Water Mark)

    @Test func processReturnsCountFromText() {
        let engine = ItemCountingEngine()
        let count = engine.process(
            formattedString: "dog, cat, tree",
            segments: makeSegments(["dog", "cat", "tree"], gaps: [0.2, 0.2])
        )
        #expect(count == 3)
    }

    @Test func countNeverDecreases() {
        let engine = ItemCountingEngine()

        // First partial: "dog, cat" → 2 items
        let count1 = engine.process(
            formattedString: "dog, cat",
            segments: makeSegments(["dog", "cat"], gaps: [0.5])
        )
        #expect(count1 == 2)

        Thread.sleep(forTimeInterval: 0.35)

        // Simulate Apple re-segmenting and temporarily removing the comma,
        // and reducing the gap. High-water mark keeps it at 2.
        let count2 = engine.process(
            formattedString: "dog cat",
            segments: makeSegments(["dog", "cat"], gaps: [0.1])
        )
        #expect(count2 == 2)
    }

    @Test func countIncreasesWhenNewItemDetected() {
        let engine = ItemCountingEngine()

        let count1 = engine.process(
            formattedString: "dog",
            segments: makeSegments(["dog"])
        )
        #expect(count1 == 1)

        Thread.sleep(forTimeInterval: 0.35)

        let count2 = engine.process(
            formattedString: "dog, cat",
            segments: makeSegments(["dog", "cat"], gaps: [0.5])
        )
        #expect(count2 == 2)

        Thread.sleep(forTimeInterval: 0.35)

        let count3 = engine.process(
            formattedString: "dog, cat, tree",
            segments: makeSegments(["dog", "cat", "tree"], gaps: [0.5, 0.5])
        )
        #expect(count3 == 3)
    }

    // MARK: - process() — Pause Detection

    @Test func pauseDetectsUnpunctuatedItems() {
        let engine = ItemCountingEngine()

        // "Bird air water" with pauses — Apple didn't add punctuation
        // but there are clear 0.5s pauses between each word
        let count = engine.process(
            formattedString: "Bird air water",
            segments: makeSegments(["Bird", "air", "water"], gaps: [0.5, 0.5])
        )
        // Pause detection: 3 items (pauses at 0.5s > 0.35s threshold)
        // Text count: 1 (no separators)
        // max(1, 3) = 3
        #expect(count == 3)
    }

    @Test func multiplePausesCountCorrectly() {
        let engine = ItemCountingEngine()

        let count = engine.process(
            formattedString: "dog cat tree bird flower",
            segments: makeSegments(
                ["dog", "cat", "tree", "bird", "flower"],
                gaps: [0.5, 0.5, 0.5, 0.5]
            )
        )
        #expect(count == 5)
    }

    @Test func shortPauseDoesNotSplit() {
        let engine = ItemCountingEngine()

        // "the blue sky" spoken fluently — gaps are tiny (0.1s)
        // Filler words "the" should not create a separate item
        let count = engine.process(
            formattedString: "the blue sky",
            segments: makeSegments(["the", "blue", "sky"], gaps: [0.1, 0.1])
        )
        #expect(count == 1)
    }

    @Test func fillerWordsFilteredFromPauseCount() {
        let engine = ItemCountingEngine()

        // "I can see a dog [pause] a cat" — filler words shouldn't inflate count
        let count = engine.process(
            formattedString: "I can see a dog a cat",
            segments: makeSegments(
                ["I", "can", "see", "a", "dog", "a", "cat"],
                gaps: [0.05, 0.05, 0.05, 0.05, 0.5, 0.05]
            )
        )
        // Pause after "dog" → group 1 has "dog" (real content), group 2 has "cat"
        // Should be 2 items
        #expect(count == 2)
    }

    @Test func pauseAndTextCountTakeMax() {
        let engine = ItemCountingEngine()

        // Text has commas AND there's a pause — should not double-count
        let count = engine.process(
            formattedString: "dog, cat",
            segments: makeSegments(["dog", "cat"], gaps: [1.0])
        )
        // Text count: 2, Pause count: 2
        // max(2, 2) = 2 (not 4)
        #expect(count == 2)
    }

    @Test func moderatePauseBetweenSingleWords() {
        let engine = ItemCountingEngine()

        // Common pattern: user says single words with ~0.4s pauses
        let count = engine.process(
            formattedString: "bird water air",
            segments: makeSegments(["bird", "water", "air"], gaps: [0.4, 0.4])
        )
        // 0.4s > 0.35s threshold → 3 items
        #expect(count == 3)
    }

    // MARK: - process() — Debounce

    @Test func debouncesSameCountWithinInterval() {
        let engine = ItemCountingEngine()

        let count1 = engine.process(
            formattedString: "dog",
            segments: makeSegments(["dog"])
        )
        #expect(count1 == 1)

        // Immediate re-process with same text (within debounce interval)
        let count2 = engine.process(
            formattedString: "dog",
            segments: makeSegments(["dog"])
        )
        #expect(count2 == nil)
    }

    @Test func emitsAfterDebounceIntervalPasses() {
        let engine = ItemCountingEngine()

        let count1 = engine.process(
            formattedString: "dog",
            segments: makeSegments(["dog"])
        )
        #expect(count1 == 1)

        Thread.sleep(forTimeInterval: 0.35)

        let count2 = engine.process(
            formattedString: "dog",
            segments: makeSegments(["dog"])
        )
        #expect(count2 == 1)
    }

    @Test func alwaysEmitsWhenCountIncreases() {
        let engine = ItemCountingEngine()

        let count1 = engine.process(
            formattedString: "dog",
            segments: makeSegments(["dog"])
        )
        #expect(count1 == 1)

        // Immediately emit higher count (no debounce for increases)
        let count2 = engine.process(
            formattedString: "dog, cat",
            segments: makeSegments(["dog", "cat"], gaps: [0.5])
        )
        #expect(count2 == 2)
    }

    // MARK: - reset()

    @Test func resetClearsState() {
        let engine = ItemCountingEngine()

        _ = engine.process(
            formattedString: "dog, cat, tree",
            segments: makeSegments(["dog", "cat", "tree"], gaps: [0.5, 0.5])
        )
        #expect(engine.stabilizedCount == 3)

        engine.reset()
        #expect(engine.stabilizedCount == 0)

        let count = engine.process(
            formattedString: "bird",
            segments: makeSegments(["bird"])
        )
        #expect(count == 1)
    }
}
