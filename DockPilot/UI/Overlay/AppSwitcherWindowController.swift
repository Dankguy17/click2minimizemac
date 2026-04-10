import AppKit
import SwiftUI

@MainActor
final class AppSwitcherWindowController: NSWindowController {
    private let service: AppSwitcherService
    private let animator = OverlayAnimator()
    private var eventMonitor: Any?
    private var globalMouseMonitor: Any?
    private let onDismiss: () -> Void

    init(service: AppSwitcherService, onDismiss: @escaping () -> Void) {
        self.service = service
        self.onDismiss = onDismiss
        let hostingController = NSHostingController(rootView: AnyView(EmptyView()))
        let panel = AppSwitcherPanel(
            contentRect: NSRect(x: 0, y: 0, width: 380, height: 420),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = false
        panel.becomesKeyOnlyIfNeeded = false
        panel.isFloatingPanel = true
        panel.hidesOnDeactivate = false
        panel.level = .floating
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.contentViewController = hostingController
        super.init(window: panel)
        hostingController.rootView = AnyView(
            AppSwitcherView(
                service: service,
                onClose: { [weak self] in
                    self?.dismissAndNotify()
                },
                onActivate: { [weak self] app in
                    _ = service.activate(app)
                    self?.dismissAndNotify()
                }
            )
        )
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func present() {
        guard let window else { return }
        center(window: window)
        installKeyboardMonitor()
        installOutsideClickMonitor()
        NSApp.activate(ignoringOtherApps: true)
        animator.show(window)
    }

    func dismiss() {
        guard let window else { return }
        removeKeyboardMonitor()
        removeOutsideClickMonitor()
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
                dismissAndNotify()
                return nil
            case 53:
                dismissAndNotify()
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

    private func installOutsideClickMonitor() {
        removeOutsideClickMonitor()
        globalMouseMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
            guard let self, let window else { return }
            if !window.frame.contains(event.locationInWindow) {
                dismissAndNotify()
            }
        }
    }

    private func removeOutsideClickMonitor() {
        if let globalMouseMonitor {
            NSEvent.removeMonitor(globalMouseMonitor)
        }
        globalMouseMonitor = nil
    }

    private func dismissAndNotify() {
        service.dismiss()
        dismiss()
        onDismiss()
    }
}
