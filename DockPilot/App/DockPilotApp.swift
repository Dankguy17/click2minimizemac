import SwiftUI

@main
struct DockPilotApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
        .commands {
            CommandGroup(replacing: .appSettings) {
                Button("Settings…") {
                    appDelegate.coordinator.openSettings()
                }
                .keyboardShortcut(",", modifiers: .command)
            }
        }
    }
}
