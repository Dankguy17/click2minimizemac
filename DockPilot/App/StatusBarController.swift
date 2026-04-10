import AppKit
import Foundation

@MainActor
final class StatusBarController: NSObject {
    var onOpenSettings: (() -> Void)?
    var onToggleFrontmost: (() -> Void)?
    var onShowSwitcher: (() -> Void)?
    var onShowPermissions: (() -> Void)?
    var onQuit: (() -> Void)?

    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

    func configure() {
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "dock.rectangle", accessibilityDescription: "DockPilot")
            button.image?.isTemplate = true
        }

        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Toggle Frontmost App", action: #selector(toggleFrontmost), keyEquivalent: "t"))
        menu.addItem(NSMenuItem(title: "Show App Switcher", action: #selector(showSwitcher), keyEquivalent: "s"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Permissions", action: #selector(showPermissions), keyEquivalent: "p"))
        menu.addItem(NSMenuItem(title: "Settings…", action: #selector(openSettings), keyEquivalent: ","))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit DockPilot", action: #selector(quit), keyEquivalent: "q"))
        menu.items.forEach { $0.target = self }
        statusItem.menu = menu
    }

    @objc private func openSettings() {
        onOpenSettings?()
    }

    @objc private func toggleFrontmost() {
        onToggleFrontmost?()
    }

    @objc private func showSwitcher() {
        onShowSwitcher?()
    }

    @objc private func showPermissions() {
        onShowPermissions?()
    }

    @objc private func quit() {
        onQuit?()
    }
}
