import Foundation

/// Utility for counting distinct items from text input.
///
/// Used in manual input mode to parse comma-separated, period-separated,
/// semicolon-separated, newline-separated, and "and"-separated lists.
enum ItemCountingEngine {

    /// Count the number of distinct items in a text string.
    ///
    /// Splits on commas, periods followed by whitespace, semicolons followed
    /// by whitespace, newlines, and the word "and" used as a list separator.
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
}
