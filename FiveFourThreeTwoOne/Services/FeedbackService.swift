import UIKit
import AudioToolbox

final class FeedbackService {
    static let shared = FeedbackService()

    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    private let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    private let notificationGenerator = UINotificationFeedbackGenerator()
    private let selectionGenerator = UISelectionFeedbackGenerator()

    private init() {
        impactLight.prepare()
        impactMedium.prepare()
        notificationGenerator.prepare()
        selectionGenerator.prepare()
    }

    /// Soft pop when a counter bubble fills in.
    func playBubbleFill() {
        impactLight.impactOccurred(intensity: 0.6)
        AudioServicesPlaySystemSound(1104) // subtle key-press tone
    }

    /// Satisfying tap when pressing the record button.
    func playRecordStart() {
        impactMedium.impactOccurred()
        AudioServicesPlaySystemSound(1113) // begin recording tone
    }

    /// Confirmation when stopping recording.
    func playRecordStop() {
        notificationGenerator.notificationOccurred(.success)
        AudioServicesPlaySystemSound(1114) // end recording tone
    }

    /// Light tap for the Next button.
    func playButtonTap() {
        selectionGenerator.selectionChanged()
        AudioServicesPlaySystemSound(1104)
    }

    /// All bubbles filled — gentle completion.
    func playAllItemsComplete() {
        impactMedium.impactOccurred(intensity: 0.8)
        AudioServicesPlaySystemSound(1075) // soft completion tap
    }
}
