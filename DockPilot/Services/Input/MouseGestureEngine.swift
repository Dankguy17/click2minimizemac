import AppKit
import Foundation

struct DetectedGesture: Hashable, Sendable {
    var kind: GestureKind
    var source: ActionSource
    var targetBundleIdentifier: String?
    var description: String
}

struct MouseGestureEngine {
    private let scrollInterpreter = ScrollGestureInterpreter()
    private let trackpadAdapter = TrackpadGestureAdapter()
    private let windowQuery: WindowQuerying
    private let spaceAwarenessService: SpaceAwarenessService

    init(windowQuery: WindowQuerying, spaceAwarenessService: SpaceAwarenessService) {
        self.windowQuery = windowQuery
        self.spaceAwarenessService = spaceAwarenessService
    }

    func detectGesture(
        from event: GlobalInputEvent,
        frontmostApp: AppDescriptor?,
        frontmostState: AppState?,
        runningApps: [AppDescriptor],
        settings: DockPilotSettings
    ) -> DetectedGesture? {
        if settings.experimental.enableDockIconInference,
           event.type == .leftMouseUp,
           let label = windowQuery.dockItemLabel(at: event.location),
           let app = runningApps.first(where: {
               $0.localizedName.localizedCaseInsensitiveContains(label) || label.localizedCaseInsensitiveContains($0.localizedName)
           }) {
            return DetectedGesture(
                kind: .dockIconClick,
                source: .dockClick,
                targetBundleIdentifier: app.bundleIdentifier,
                description: "Dock item inferred from AX hit test"
            )
        }

        guard let frontmostApp, let frontmostState else { return nil }

        if event.type == .leftMouseUp,
           event.clickCount >= 2,
           settings.gestures.enableTitleBarGestures,
           isTitleBarTarget(event.location, state: frontmostState) {
            return DetectedGesture(
                kind: .titleBarDoubleClick,
                source: .titleBarGesture,
                targetBundleIdentifier: frontmostApp.bundleIdentifier,
                description: "Title bar double-click"
            )
        }

        if event.type == .scrollWheel,
           settings.gestures.enableScrollGestures,
           isTitleBarTarget(event.location, state: frontmostState),
           let kind = scrollInterpreter.gesture(for: event.deltaY) {
            return DetectedGesture(
                kind: kind,
                source: .titleBarGesture,
                targetBundleIdentifier: frontmostApp.bundleIdentifier,
                description: "Title bar scroll gesture"
            )
        }

        if event.type == .scrollWheel,
           settings.gestures.enableTrackpadModifierGestures,
           let kind = trackpadAdapter.gesture(for: event) {
            return DetectedGesture(
                kind: kind,
                source: .titleBarGesture,
                targetBundleIdentifier: frontmostApp.bundleIdentifier,
                description: "Modifier-assisted trackpad gesture"
            )
        }

        if event.type == .otherMouseDown, settings.gestures.enableRockerGestures {
            let kind: GestureKind = event.buttonNumber == 3 ? .rockerLeft : .rockerRight
            return DetectedGesture(
                kind: kind,
                source: .titleBarGesture,
                targetBundleIdentifier: frontmostApp.bundleIdentifier,
                description: "Mouse rocker gesture"
            )
        }

        if event.type == .leftMouseUp,
           settings.gestures.enableNotchTrigger,
           let screen = spaceAwarenessService.screen(containing: event.location),
           spaceAwarenessService.notchZone(for: screen).contains(event.location) {
            return DetectedGesture(
                kind: .notchClick,
                source: .notchGesture,
                targetBundleIdentifier: frontmostApp.bundleIdentifier,
                description: "Notch-area gesture"
            )
        }

        return nil
    }

    private func isTitleBarTarget(_ point: CGPoint, state: AppState) -> Bool {
        guard let frame = state.actionableWindows.first?.frame else { return false }
        return spaceAwarenessService.titleBarZone(for: frame).contains(point)
    }
}
