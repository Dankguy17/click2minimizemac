import CoreGraphics
import Foundation

@MainActor
final class RestoreEngine {
    private let frameStore: WindowFrameStore

    init(frameStore: WindowFrameStore) {
        self.frameStore = frameStore
    }

    func save(frame: CGRect, for windowID: String) {
        frameStore.store(frame: frame, for: windowID)
    }

    func restoreFrame(for windowID: String) -> CGRect? {
        frameStore.frame(for: windowID)
    }
}
