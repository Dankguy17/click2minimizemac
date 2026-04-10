import Foundation

struct ScrollGestureInterpreter {
    let threshold: Double = 4

    func gesture(for deltaY: Double) -> GestureKind? {
        if deltaY >= threshold {
            return .scrollUp
        }
        if deltaY <= -threshold {
            return .scrollDown
        }
        return nil
    }
}
