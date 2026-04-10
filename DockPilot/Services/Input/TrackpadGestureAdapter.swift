import Foundation

struct TrackpadGestureAdapter {
    func gesture(for event: GlobalInputEvent) -> GestureKind? {
        guard event.type == .scrollWheel, event.modifiers.contains(.option), abs(event.deltaY) > 8 else {
            return nil
        }
        return .trackpadModifierSwipe
    }
}
