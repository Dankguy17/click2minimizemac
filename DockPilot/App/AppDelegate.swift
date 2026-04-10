import AppKit
import Foundation

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    let coordinator = AppCoordinator()
    private let isRunningTests = ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        guard !isRunningTests else { return }
        coordinator.start()
    }

    func applicationWillTerminate(_ notification: Notification) {
        guard !isRunningTests else { return }
        coordinator.stop()
    }
}
