import AppKit
import CoreGraphics
import Foundation

struct SnapEngine {
    enum SnapSide {
        case left
        case right
        case fill
    }

    func targetFrame(for originalFrame: CGRect, on screen: NSScreen, side: SnapSide, padding: CGFloat, useVisibleFrame: Bool) -> CGRect {
        let bounds = useVisibleFrame ? screen.visibleFrame : screen.frame
        return targetFrame(for: originalFrame, within: bounds, side: side, padding: padding)
    }

    func targetFrame(for originalFrame: CGRect, within bounds: CGRect, side: SnapSide, padding: CGFloat) -> CGRect {
        let padded = bounds.insetBy(dx: padding, dy: padding)

        switch side {
        case .left:
            return CGRect(
                x: padded.minX,
                y: padded.minY,
                width: max(320, padded.width / 2 - (padding / 2)),
                height: padded.height
            )
        case .right:
            return CGRect(
                x: padded.midX + (padding / 2),
                y: padded.minY,
                width: max(320, padded.width / 2 - (padding / 2)),
                height: padded.height
            )
        case .fill:
            return padded
        }
    }
}
