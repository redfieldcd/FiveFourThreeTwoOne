import Testing
import Foundation
import SwiftData
@testable import FiveFourThreeTwoOne

struct SenseEntryTests {
    @Test func initSetsSenseTypeRawValue() {
        let entry = SenseEntry(senseType: .hear, transcribedText: "birds chirping")
        #expect(entry.senseTypeRaw == 3)
        #expect(entry.senseType == .hear)
    }

    @Test func senseTypeComputedPropertyRoundTrips() {
        let entry = SenseEntry(senseType: .see)
        #expect(entry.senseType == .see)
        #expect(entry.senseTypeRaw == 5)

        entry.senseType = .taste
        #expect(entry.senseTypeRaw == 1)
        #expect(entry.senseType == .taste)
    }

    @Test func audioFileURLIsNilWhenNoFileName() {
        let entry = SenseEntry(senseType: .see, transcribedText: "test")
        #expect(entry.audioFileURL == nil)
    }

    @Test func audioFileURLConstructedCorrectly() {
        let entry = SenseEntry(senseType: .see, transcribedText: "test", audioFileName: "test.m4a")
        let url = entry.audioFileURL
        #expect(url != nil)
        #expect(url!.lastPathComponent == "test.m4a")
        #expect(url!.pathComponents.contains("Audio"))
    }

    @Test func transcribedTextIsStored() {
        let entry = SenseEntry(senseType: .touch, transcribedText: "smooth table")
        #expect(entry.transcribedText == "smooth table")
    }

    @Test func defaultTranscribedTextIsEmpty() {
        let entry = SenseEntry(senseType: .smell)
        #expect(entry.transcribedText == "")
    }

    @Test func createdAtDefaultsToNow() {
        let before = Date.now
        let entry = SenseEntry(senseType: .see)
        let after = Date.now
        #expect(entry.createdAt >= before)
        #expect(entry.createdAt <= after)
    }
}
