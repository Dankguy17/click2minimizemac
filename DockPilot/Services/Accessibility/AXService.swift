import ApplicationServices
import AppKit
import Foundation

protocol AccessibilityServing {
    func isTrusted(prompt: Bool) -> Bool
    func appElement(for application: NSRunningApplication) -> AXUIElement
}

struct AXService: AccessibilityServing {
    func isTrusted(prompt: Bool) -> Bool {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: prompt] as CFDictionary
        return AXIsProcessTrustedWithOptions(options)
    }

    func appElement(for application: NSRunningApplication) -> AXUIElement {
        AXUIElementCreateApplication(application.processIdentifier)
    }
}
