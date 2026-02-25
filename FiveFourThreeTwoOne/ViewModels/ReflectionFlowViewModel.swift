import SwiftUI
import SwiftData

@MainActor
@Observable
final class ReflectionFlowViewModel {
    private let modelContext: ModelContext
    private let voiceGuide: any VoiceGuiding

    var currentStepIndex: Int = 0
    var reflection: Reflection
    var isFlowComplete: Bool = false
    var isGuidanceSpeaking: Bool = false

    /// Location name fetched at the start of the session.
    private var fetchedLocationName: String?

    var currentSenseType: SenseType {
        SenseType.orderedCases[currentStepIndex]
    }

    var totalSteps: Int { SenseType.allCases.count }
    var progress: Double { Double(currentStepIndex) / Double(totalSteps) }

    init(modelContext: ModelContext, voiceGuide: any VoiceGuiding) {
        self.modelContext = modelContext
        self.voiceGuide = voiceGuide
        self.reflection = Reflection()
        modelContext.insert(reflection)

        // Fetch location in the background as soon as the flow starts
        Task {
            let name = await LocationService.shared.fetchCurrentLocationName()
            self.fetchedLocationName = name
        }
    }

    func speakGuidance() async {
        isGuidanceSpeaking = true
        await voiceGuide.speak(currentSenseType.guidancePrompt, for: currentSenseType)
        isGuidanceSpeaking = false
    }

    func commitEntry(_ entry: SenseEntry) {
        reflection.entries.append(entry)

        if currentStepIndex < totalSteps - 1 {
            currentStepIndex += 1
        } else {
            reflection.isComplete = true
            reflection.locationName = fetchedLocationName
            reflection.title = fetchedLocationName
                ?? "Reflection - \(reflection.createdAt.formatted(date: .abbreviated, time: .shortened))"
            try? modelContext.save()
            isFlowComplete = true
        }
    }

    func cancelFlow() {
        for entry in reflection.entries {
            if let url = entry.audioFileURL {
                try? FileManager.default.removeItem(at: url)
            }
        }
        modelContext.delete(reflection)
        try? modelContext.save()
    }
}
