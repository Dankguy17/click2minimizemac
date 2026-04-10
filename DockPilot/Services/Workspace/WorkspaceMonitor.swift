import AppKit
import Foundation

@MainActor
final class WorkspaceMonitor {
    var onFrontmostAppChanged: ((AppDescriptor?) -> Void)?
    var onRunningAppsChanged: (() -> Void)?

    private var observers: [NSObjectProtocol] = []

    func start() {
        let workspace = NSWorkspace.shared.notificationCenter
        observers.append(
            workspace.addObserver(
                forName: NSWorkspace.didActivateApplicationNotification,
                object: nil,
                queue: .main
            ) { [weak self] notification in
                let application = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication
                self?.onFrontmostAppChanged?(application.map(AppDescriptor.init))
            }
        )

        let names: [NSNotification.Name] = [
            NSWorkspace.didLaunchApplicationNotification,
            NSWorkspace.didTerminateApplicationNotification,
            NSWorkspace.didHideApplicationNotification,
            NSWorkspace.didUnhideApplicationNotification,
        ]

        for name in names {
            observers.append(
                workspace.addObserver(
                    forName: name,
                    object: nil,
                    queue: .main
                ) { [weak self] _ in
                    self?.onRunningAppsChanged?()
                }
            )
        }
    }

    func stop() {
        let workspace = NSWorkspace.shared.notificationCenter
        observers.forEach { workspace.removeObserver($0) }
        observers.removeAll()
    }
}
