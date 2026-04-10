import AppKit
import Foundation

struct SpaceAwarenessService {
    func isLikelyFullscreen(window: WindowDescriptor) -> Bool {
        window.isFullscreen
    }

    func activeDisplays() -> [NSScreen] {
        NSScreen.screens
    }

    func screen(containing point: CGPoint) -> NSScreen? {
        NSScreen.screens.first { $0.frame.contains(point) }
    }

    func titleBarZone(for frame: CGRect) -> CGRect {
        CGRect(x: frame.minX, y: frame.maxY - 56, width: frame.width, height: 56)
    }

    func notchZone(for screen: NSScreen) -> CGRect {
        let visible = screen.frame
        let width: CGFloat = min(280, visible.width * 0.2)
        return CGRect(
            x: visible.midX - (width / 2),
            y: visible.maxY - 40,
            width: width,
            height: 40
        )
    }
}
