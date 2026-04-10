import AppKit
import SwiftUI

@MainActor
final class SettingsWindowController: NSWindowController {
    init(coordinator: AppCoordinator) {
        let rootView = SettingsRootView(coordinator: coordinator)
        let hostingController = NSHostingController(rootView: rootView)
        let window = NSWindow(contentViewController: hostingController)
        window.title = "DockPilot Settings"
        window.setContentSize(NSSize(width: 980, height: 720))
        window.styleMask.formUnion([.titled, .closable, .miniaturizable, .resizable])
        super.init(window: window)
        shouldCascadeWindows = true
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
