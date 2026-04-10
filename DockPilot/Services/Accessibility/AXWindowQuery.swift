import ApplicationServices
import AppKit
import Foundation

protocol WindowQuerying {
    func windows(for application: NSRunningApplication) -> [WindowDescriptor]
    func dockItemLabel(at point: CGPoint) -> String?
}

struct AXWindowQuery: WindowQuerying {
    private let fullscreenAttribute = "AXFullScreen" as CFString
    private let service: AccessibilityServing
    private let reader = AXAttributeReader()

    init(service: AccessibilityServing) {
        self.service = service
    }

    func windows(for application: NSRunningApplication) -> [WindowDescriptor] {
        let appElement = service.appElement(for: application)
        guard let elements: [AXUIElement] = reader.value(for: kAXWindowsAttribute as CFString, on: appElement, as: [AXUIElement].self) else {
            return []
        }

        return elements.compactMap { element in
            let frame = reader.cgPoint(for: kAXPositionAttribute as CFString, on: element).flatMap { origin in
                reader.cgSize(for: kAXSizeAttribute as CFString, on: element).map { size in
                    CGRect(origin: origin, size: size)
                }
            }

            guard let frame else { return nil }

            let title = reader.value(for: kAXTitleAttribute as CFString, on: element, as: String.self) ?? application.localizedName ?? "Window"
            let minimized = reader.bool(for: kAXMinimizedAttribute as CFString, on: element) ?? false
            let fullscreen = reader.bool(for: fullscreenAttribute, on: element) ?? false
            let main = reader.bool(for: kAXMainAttribute as CFString, on: element) ?? false
            let key = reader.bool(for: kAXFocusedAttribute as CFString, on: element) ?? false
            let role = reader.value(for: kAXRoleAttribute as CFString, on: element, as: String.self)
            let subrole = reader.value(for: kAXSubroleAttribute as CFString, on: element, as: String.self)
            let identifier = "\(application.processIdentifier)-\(title)-\(Int(frame.origin.x))-\(Int(frame.origin.y))-\(Int(frame.width))-\(Int(frame.height))"

            return WindowDescriptor(
                id: identifier,
                title: title,
                appBundleIdentifier: application.bundleIdentifier ?? "unknown.bundle",
                ownerProcessIdentifier: application.processIdentifier,
                frame: frame,
                isMain: main,
                isKey: key,
                isMinimized: minimized,
                isVisible: !minimized && !frame.isEmpty,
                isFullscreen: fullscreen,
                isStandardWindow: role == kAXWindowRole as String,
                role: role,
                subrole: subrole
            )
        }
    }

    func dockItemLabel(at point: CGPoint) -> String? {
        guard let dock = NSWorkspace.shared.runningApplications.first(where: { $0.bundleIdentifier == "com.apple.dock" }) else {
            return nil
        }

        let dockElement = service.appElement(for: dock)
        var hitElement: AXUIElement?
        let error = AXUIElementCopyElementAtPosition(dockElement, Float(point.x), Float(point.y), &hitElement)
        guard error == .success, let hitElement else {
            return nil
        }

        return reader.value(for: kAXTitleAttribute as CFString, on: hitElement, as: String.self)
            ?? reader.value(for: kAXDescriptionAttribute as CFString, on: hitElement, as: String.self)
    }
}
