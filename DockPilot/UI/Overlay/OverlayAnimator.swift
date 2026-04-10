import AppKit
import Foundation

struct OverlayAnimator {
    func show(_ window: NSWindow) {
        window.alphaValue = 0
        window.makeKeyAndOrderFront(nil)
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.14
            window.animator().alphaValue = 1
        }
    }

    func hide(_ window: NSWindow) {
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.12
            window.animator().alphaValue = 0
        } completionHandler: {
            window.orderOut(nil)
        }
    }
}
