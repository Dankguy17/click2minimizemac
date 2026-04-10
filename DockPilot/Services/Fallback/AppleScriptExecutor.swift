import AppKit
import Foundation

struct AppleScriptExecutor {
    func activate(bundleIdentifier: String) -> Bool {
        execute("""
        tell application id "\(bundleIdentifier)"
            activate
        end tell
        """)
    }

    func hide(bundleIdentifier: String) -> Bool {
        execute("""
        tell application id "\(bundleIdentifier)"
            hide
        end tell
        """)
    }

    private func execute(_ source: String) -> Bool {
        var error: NSDictionary?
        let script = NSAppleScript(source: source)
        script?.executeAndReturnError(&error)
        return error == nil
    }
}
