import Foundation
import Testing
@testable import FiveFourThreeTwoOne

struct ItemCountingEngineTests {

    // MARK: - countItems(in:) — Text-Based Counting

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
}
