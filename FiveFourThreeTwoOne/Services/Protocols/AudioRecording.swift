import Foundation

protocol AudioRecording: AnyObject {
    var isRecording: Bool { get }

    func startRecording(to fileURL: URL) throws
    func stopRecording() -> URL?
}
