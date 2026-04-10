import AppKit
import Foundation

struct ModifierStateMonitor {
    func modifiers(from flags: NSEvent.ModifierFlags) -> Set<KeyboardModifier> {
        var modifiers: Set<KeyboardModifier> = []
        if flags.contains(.command) { modifiers.insert(.command) }
        if flags.contains(.option) { modifiers.insert(.option) }
        if flags.contains(.control) { modifiers.insert(.control) }
        if flags.contains(.shift) { modifiers.insert(.shift) }
        if flags.contains(.function) { modifiers.insert(.function) }
        return modifiers
    }
}
