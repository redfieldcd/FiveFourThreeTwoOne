import Testing
@testable import FiveFourThreeTwoOne

struct SenseTypeTests {
    @Test func allCasesContainsFiveItems() {
        #expect(SenseType.allCases.count == 5)
    }

    @Test func seeCountIsFive() {
        #expect(SenseType.see.count == 5)
    }

    @Test func touchCountIsFour() {
        #expect(SenseType.touch.count == 4)
    }

    @Test func hearCountIsThree() {
        #expect(SenseType.hear.count == 3)
    }

    @Test func smellCountIsTwo() {
        #expect(SenseType.smell.count == 2)
    }

    @Test func tasteCountIsOne() {
        #expect(SenseType.taste.count == 1)
    }

    @Test func stepIndexOrdering() {
        #expect(SenseType.see.stepIndex == 0)
        #expect(SenseType.touch.stepIndex == 1)
        #expect(SenseType.hear.stepIndex == 2)
        #expect(SenseType.smell.stepIndex == 3)
        #expect(SenseType.taste.stepIndex == 4)
    }

    @Test func orderedCasesMatchesStepIndexOrder() {
        let ordered = SenseType.orderedCases
        #expect(ordered[0] == .see)
        #expect(ordered[1] == .touch)
        #expect(ordered[2] == .hear)
        #expect(ordered[3] == .smell)
        #expect(ordered[4] == .taste)
    }

    @Test func displayNamesAreNonEmpty() {
        for senseType in SenseType.allCases {
            #expect(!senseType.displayName.isEmpty)
        }
    }

    @Test func sfSymbolsAreNonEmpty() {
        for senseType in SenseType.allCases {
            #expect(!senseType.sfSymbol.isEmpty)
        }
    }

    @Test func guidancePromptsAreNonEmpty() {
        for senseType in SenseType.allCases {
            #expect(!senseType.guidancePrompt.isEmpty)
        }
    }

    @Test func rawValueRoundTrip() {
        for senseType in SenseType.allCases {
            let restored = SenseType(rawValue: senseType.rawValue)
            #expect(restored == senseType)
        }
    }

    @Test func idMatchesRawValue() {
        for senseType in SenseType.allCases {
            #expect(senseType.id == senseType.rawValue)
        }
    }
}
