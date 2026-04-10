import AppKit
import SwiftUI

@MainActor
final class AppSwitcherWindowController: NSWindowController {
    private let service: AppSwitcherService
    private let animator = OverlayAnimator()
    private var eventMonitor: Any?

    init(service: AppSwitcherService) {
        self.service = service
        let hostingController = NSHostingController(rootView: AppSwitcherView(service: service))
        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 380, height: 420),
            styleMask: [.nonactivatingPanel, .borderless],
            backing: .buffered,
            defer: false
        )
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = false
        panel.level = .floating
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.contentViewController = hostingController
        super.init(window: panel)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func present() {
        guard let window else { return }
        center(window: window)
        installKeyboardMonitor()
        animator.show(window)
    }

    func dismiss() {
        guard let window else { return }
        removeKeyboardMonitor()
        animator.hide(window)
    }

    private func center(window: NSWindow) {
        guard let screen = NSScreen.main else { return }
        let frame = window.frame
        let screenFrame = screen.visibleFrame
        let origin = CGPoint(
            x: screenFrame.midX - (frame.width / 2),
            y: screenFrame.midY - (frame.height / 2)
        )
        window.setFrameOrigin(origin)
    }

    private func installKeyboardMonitor() {
        removeKeyboardMonitor()
        eventMonitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown]) { [weak self] event in
            guard let self else { return event }
            switch event.keyCode {
            case 125:
                service.moveSelection(delta: 1)
                return nil
            case 126:
                service.moveSelection(delta: -1)
                return nil
            case 36:
                _ = service.activateSelected()
                dismiss()
                return nil
            case 53:
                service.dismiss()
                dismiss()
                return nil
            default:
                return event
            }
        }
    }

    private func removeKeyboardMonitor() {
        if let eventMonitor {
            NSEvent.removeMonitor(eventMonitor)
        }
        eventMonitor = nil
    }
}
