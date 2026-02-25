import AVFoundation
import Speech

enum PermissionStatus {
    case notDetermined
    case granted
    case denied
}

struct PermissionsState {
    var microphone: PermissionStatus
    var speechRecognition: PermissionStatus

    var allGranted: Bool {
        microphone == .granted && speechRecognition == .granted
    }
}

final class PermissionsService {
    static func currentState() -> PermissionsState {
        let micStatus: PermissionStatus
        switch AVAudioApplication.shared.recordPermission {
        case .undetermined: micStatus = .notDetermined
        case .granted: micStatus = .granted
        case .denied: micStatus = .denied
        @unknown default: micStatus = .denied
        }

        let speechStatus: PermissionStatus
        switch SFSpeechRecognizer.authorizationStatus() {
        case .notDetermined: speechStatus = .notDetermined
        case .authorized: speechStatus = .granted
        case .denied, .restricted: speechStatus = .denied
        @unknown default: speechStatus = .denied
        }

        return PermissionsState(microphone: micStatus, speechRecognition: speechStatus)
    }

    static func requestMicrophoneAccess() async -> Bool {
        await AVAudioApplication.requestRecordPermission()
    }

    static func requestSpeechRecognitionAccess() async -> Bool {
        await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }
    }

    static func requestAllPermissions() async -> PermissionsState {
        let mic = await requestMicrophoneAccess()
        let speech = await requestSpeechRecognitionAccess()
        return PermissionsState(
            microphone: mic ? .granted : .denied,
            speechRecognition: speech ? .granted : .denied
        )
    }
}
