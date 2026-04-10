import CoreGraphics
import Foundation

@MainActor
final class WindowFrameStore {
    private var frames: [String: CGRect] = [:]

    func store(frame: CGRect, for key: String) {
        frames[key] = frame
    }

    func frame(for key: String) -> CGRect? {
        frames[key]
    }
}
