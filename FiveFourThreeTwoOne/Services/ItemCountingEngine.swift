import Foundation

/// A three-layer engine for counting distinct items from speech recognition output.
///
/// Layer 1 (Primary): Text-based parsing of the `formattedString` — splits on commas,
/// periods, semicolons, newlines, and the word "and". This is where Apple places
/// punctuation when `addsPunctuation` is enabled.
///
/// Layer 2 (Secondary): Pause-boost detection — identifies large pauses (≥ 0.8s) in
/// segment timestamps that Apple hasn't yet punctuated (common during partial results).
///
/// Layer 3 (Stabilization): High-water mark ensures the count never decreases, and
/// debouncing suppresses redundant emissions to avoid UI flicker.
final class ItemCountingEngine {

    /// Represents a single speech segment with timing information.
    struct Segment {
        let substring: String
        let timestamp: TimeInterval
        let duration: TimeInterval
    }

    // MARK: - Configuration

    /// Minimum pause (seconds) between segments to count as a new item via pause detection.
    /// Set low (0.35s) because users in this app are listing short items (single words or
    /// brief phrases) with natural pauses between them — not speaking in flowing sentences.
    private let pauseThreshold: TimeInterval = 0.35

    /// Minimum interval (seconds) between count emissions to suppress duplicate yields.
    private let debounceInterval: TimeInterval = 0.3

    // MARK: - State

    /// High-water mark: the count only ever goes up.
    private(set) var stabilizedCount: Int = 0

    /// Timestamp of the last emitted count change, for debounce logic.
    private var lastEmitTime: CFAbsoluteTime = 0

    // MARK: - Public API

    /// Shared text-based item counter used by both voice and manual input modes.
    ///
    /// Splits on commas, periods followed by whitespace, semicolons followed by whitespace,
    /// newlines, and the word "and" used as a list separator.
    static func countItems(in text: String) -> Int {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return 0 }

        // Pattern matches common list separators:
        //   ,        — comma
        //   \.\s     — period followed by whitespace
        //   ;\s      — semicolon followed by whitespace
        //   \n       — newline
        //   \band\b  — the word "and" surrounded by word boundaries
        let separatorPattern = #",|\.\s|;\s|\n|\band\b"#

        let segments = trimmed
            .replacingOccurrences(
                of: separatorPattern,
                with: "|||",
                options: .regularExpression
            )
            .components(separatedBy: "|||")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        return max(segments.count, 1)
    }

    /// Process a new transcription result and return the stabilized count,
    /// or `nil` if the emission should be suppressed (debounced or unchanged).
    ///
    /// - Parameters:
    ///   - formattedString: The full transcription text with Apple-inserted punctuation.
    ///   - segments: Timing data for each recognized word.
    /// - Returns: The new item count to emit, or `nil` to suppress.
    func process(formattedString: String, segments: [Segment]) -> Int? {
        let textCount = Self.countItems(in: formattedString)
        let pauseCount = countItemsFromPauses(in: segments)

        // Fuse the two signals by taking the maximum.
        // We do NOT add them because the same item boundary can appear as
        // both a comma in the text and a pause in the timestamps.
        let rawCount = max(textCount, pauseCount)

        // Apply high-water mark: count never decreases.
        let newCount = max(rawCount, stabilizedCount)

        // Debounce: suppress if count is unchanged and within the debounce window.
        let now = CFAbsoluteTimeGetCurrent()
        if newCount == stabilizedCount && (now - lastEmitTime) < debounceInterval {
            return nil
        }

        stabilizedCount = newCount
        lastEmitTime = now
        return newCount
    }

    /// Reset all state for a new recording session.
    func reset() {
        stabilizedCount = 0
        lastEmitTime = 0
    }

    // MARK: - Private

    /// Count distinct items by detecting pauses between speech segments.
    ///
    /// In this app, users list short items ("bird", "air", "water") with natural pauses
    /// between them. Each pause ≥ `pauseThreshold` indicates a new item. The method also
    /// filters out connector words ("and", "the", "a", "um", "uh") that appear between
    /// items so they don't inflate the count.
    private func countItemsFromPauses(in segments: [Segment]) -> Int {
        guard !segments.isEmpty else { return 0 }

        // Connector/filler words that should not be counted as separate items
        let fillerWords: Set<String> = [
            "and", "the", "a", "an", "um", "uh", "like", "so", "then", "also",
            "i", "can", "see", "hear", "smell", "taste", "feel", "touch"
        ]

        // Group consecutive segments into items separated by pauses.
        // Start with 1 item (the first thing they say).
        var count = 0
        var currentGroupHasContent = false

        for i in 0..<segments.count {
            let word = segments[i].substring
                .lowercased()
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .trimmingCharacters(in: .punctuationCharacters)

            let isFillerWord = fillerWords.contains(word)

            // Check if there's a pause before this segment
            if i > 0 {
                let prevEnd = segments[i - 1].timestamp + segments[i - 1].duration
                let gap = segments[i].timestamp - prevEnd

                if gap >= pauseThreshold {
                    // A pause was detected. If the previous group had real content, it was an item.
                    if currentGroupHasContent {
                        count += 1
                    }
                    currentGroupHasContent = false
                }
            }

            // Mark that this group has real (non-filler) content
            if !isFillerWord && !word.isEmpty {
                currentGroupHasContent = true
            }
        }

        // Don't forget the last group
        if currentGroupHasContent {
            count += 1
        }

        return count
    }
}
