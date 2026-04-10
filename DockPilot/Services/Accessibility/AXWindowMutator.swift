import ApplicationServices
import AppKit
import Foundation

@MainActor
final class AXWindowMutator: AppWindowMutating {
    private let fullscreenAttribute = "AXFullScreen" as CFString
    private let query: WindowQuerying
    private let service: AccessibilityServing
    private let reader = AXAttributeReader()
    private let snapEngine: SnapEngine
    private let restoreEngine: RestoreEngine
    private let settingsProvider: () -> DockPilotSettings

    init(
        query: WindowQuerying,
        service: AccessibilityServing,
        snapEngine: SnapEngine,
        restoreEngine: RestoreEngine,
        settingsProvider: @escaping () -> DockPilotSettings
    ) {
        self.query = query
        self.service = service
        self.snapEngine = snapEngine
        self.restoreEngine = restoreEngine
        self.settingsProvider = settingsProvider
    }

    func activate(_ application: NSRunningApplication) -> Bool {
        application.activate(options: [.activateAllWindows, .activateIgnoringOtherApps])
    }

    func unhide(_ application: NSRunningApplication) -> Bool {
        application.unhide()
        return application.activate(options: [.activateAllWindows, .activateIgnoringOtherApps])
    }

    func hide(_ application: NSRunningApplication) -> Bool {
        application.hide()
        return true
    }

    func bringAllToFront(_ application: NSRunningApplication) -> Bool {
        application.activate(options: [.activateAllWindows, .activateIgnoringOtherApps])
    }

    func minimizeWindows(of application: NSRunningApplication, matching ids: [String]) -> Bool {
        mutateWindows(of: application, matching: ids) { element, _ in
            let value = NSNumber(value: true)
            return AXUIElementSetAttributeValue(element, kAXMinimizedAttribute as CFString, value) == .success
        }
    }

    func restoreWindows(of application: NSRunningApplication, matching ids: [String]) -> Bool {
        mutateWindows(of: application, matching: ids) { element, _ in
            let value = NSNumber(value: false)
            return AXUIElementSetAttributeValue(element, kAXMinimizedAttribute as CFString, value) == .success
        }
    }

    func toggleFullscreen(of application: NSRunningApplication, matching ids: [String]) -> Bool {
        mutateWindows(of: application, matching: ids) { [reader, fullscreenAttribute] element, _ in
            let current = reader.bool(for: fullscreenAttribute, on: element) ?? false
            return AXUIElementSetAttributeValue(
                element,
                fullscreenAttribute,
                NSNumber(value: !current)
            ) == .success
        }
    }

    func snapLeft(of application: NSRunningApplication, matching ids: [String]) -> Bool {
        resize(of: application, matching: ids, side: .left)
    }

    func snapRight(of application: NSRunningApplication, matching ids: [String]) -> Bool {
        resize(of: application, matching: ids, side: .right)
    }

    func fill(of application: NSRunningApplication, matching ids: [String]) -> Bool {
        resize(of: application, matching: ids, side: .fill)
    }

    func restoreFrame(of application: NSRunningApplication, matching ids: [String]) -> Bool {
        mutateWindows(of: application, matching: ids) { [restoreEngine] element, window in
            guard let frame = awaitMain({ restoreEngine.restoreFrame(for: window.id) }) else {
                return false
            }
            return set(frame: frame, on: element)
        }
    }

    private func resize(of application: NSRunningApplication, matching ids: [String], side: SnapEngine.SnapSide) -> Bool {
        let settings = settingsProvider()
        return mutateWindows(of: application, matching: ids) { [snapEngine, restoreEngine] element, window in
            guard let screen = NSScreen.screens.first(where: { $0.frame.intersects(window.frame) }) ?? NSScreen.main else {
                return false
            }
            awaitMain { restoreEngine.save(frame: window.frame, for: window.id) }
            let newFrame = snapEngine.targetFrame(
                for: window.frame,
                on: screen,
                side: side,
                padding: settings.snapping.padding,
                useVisibleFrame: settings.snapping.useVisibleFrame
            )
            return set(frame: newFrame, on: element)
        }
    }

    private func mutateWindows(
        of application: NSRunningApplication,
        matching ids: [String],
        mutation: (AXUIElement, WindowDescriptor) -> Bool
    ) -> Bool {
        let appElement = service.appElement(for: application)
        guard let elements: [AXUIElement] = reader.value(for: kAXWindowsAttribute as CFString, on: appElement, as: [AXUIElement].self) else {
            return false
        }
        let descriptors = query.windows(for: application)
        let descriptorMap = Dictionary(uniqueKeysWithValues: descriptors.map { ($0.id, $0) })
        let targetIDs = ids.isEmpty ? Set(descriptors.map(\.id)) : Set(ids)

        var touched = false
        for element in elements {
            guard let descriptor = descriptor(for: element, application: application, descriptorMap: descriptorMap) else {
                continue
            }
            guard targetIDs.contains(descriptor.id) else { continue }
            touched = mutation(element, descriptor) || touched
        }
        return touched
    }

    private func descriptor(
        for element: AXUIElement,
        application: NSRunningApplication,
        descriptorMap: [String: WindowDescriptor]
    ) -> WindowDescriptor? {
        let title = reader.value(for: kAXTitleAttribute as CFString, on: element, as: String.self) ?? application.localizedName ?? "Window"
        let frame = reader.cgPoint(for: kAXPositionAttribute as CFString, on: element).flatMap { origin in
            reader.cgSize(for: kAXSizeAttribute as CFString, on: element).map { size in
                CGRect(origin: origin, size: size)
            }
        } ?? .zero
        let identifier = "\(application.processIdentifier)-\(title)-\(Int(frame.origin.x))-\(Int(frame.origin.y))-\(Int(frame.width))-\(Int(frame.height))"
        return descriptorMap[identifier]
    }

    private func set(frame: CGRect, on element: AXUIElement) -> Bool {
        var origin = frame.origin
        var size = frame.size
        guard let positionValue = AXValueCreate(.cgPoint, &origin),
              let sizeValue = AXValueCreate(.cgSize, &size) else {
            return false
        }

        let positionResult = AXUIElementSetAttributeValue(element, kAXPositionAttribute as CFString, positionValue)
        let sizeResult = AXUIElementSetAttributeValue(element, kAXSizeAttribute as CFString, sizeValue)
        return positionResult == .success && sizeResult == .success
    }

    private func awaitMain<T>(_ work: @MainActor () -> T) -> T {
        MainActor.assumeIsolated(work)
    }
}
