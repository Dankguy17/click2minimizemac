import Foundation

struct DockPilotSettings: Codable, Hashable, Sendable {
    var schemaVersion: Int
    var general: General
    var dockBehavior: DockBehavior
    var gestures: Gestures
    var appSwitcher: AppSwitcher
    var snapping: Snapping
    var diagnostics: Diagnostics
    var experimental: Experimental
    var gestureDefinitions: [GestureDefinition]

    init(
        schemaVersion: Int = 1,
        general: General = .init(),
        dockBehavior: DockBehavior = .init(),
        gestures: Gestures = .init(),
        appSwitcher: AppSwitcher = .init(),
        snapping: Snapping = .init(),
        diagnostics: Diagnostics = .init(),
        experimental: Experimental = .init(),
        gestureDefinitions: [GestureDefinition] = GestureDefinition.defaults
    ) {
        self.schemaVersion = schemaVersion
        self.general = general
        self.dockBehavior = dockBehavior
        self.gestures = gestures
        self.appSwitcher = appSwitcher
        self.snapping = snapping
        self.diagnostics = diagnostics
        self.experimental = experimental
        self.gestureDefinitions = gestureDefinitions
    }

    struct General: Codable, Hashable, Sendable {
        var openSettingsAtLaunch: Bool = false
        var showPermissionOnboardingOnLaunch: Bool = true
    }

    struct DockBehavior: Codable, Hashable, Sendable {
        var isEnabled: Bool = true
        var singleClickSemanticToggle: Bool = true
        var prefersHideOverMinimize: Bool = false
        var multiWindowPolicy: MultiWindowPolicy = .allWindows
        var stageManagerCompatibilityMode: Bool = true
        var fullscreenSafetyMode: Bool = true
        var enableAppleScriptFallback: Bool = true
    }

    struct Gestures: Codable, Hashable, Sendable {
        var enableTitleBarGestures: Bool = true
        var enableNotchTrigger: Bool = true
        var enableScrollGestures: Bool = true
        var enableRockerGestures: Bool = true
        var enableTrackpadModifierGestures: Bool = true
    }

    struct AppSwitcher: Codable, Hashable, Sendable {
        var showPreviews: Bool = false
        var showMetadata: Bool = true
        var dismissOnActivate: Bool = true
        var useRecentOrder: Bool = true
    }

    struct Snapping: Codable, Hashable, Sendable {
        var rememberFrames: Bool = true
        var useVisibleFrame: Bool = true
        var padding: Double = 10
    }

    struct Diagnostics: Codable, Hashable, Sendable {
        var verboseLogging: Bool = true
        var retainedEventCount: Int = 200
    }

    struct Experimental: Codable, Hashable, Sendable {
        var enableDockIconInference: Bool = true
        var enableDockLockHeuristics: Bool = true
        var enableWorkspaceCycling: Bool = false
    }

    static let `default` = DockPilotSettings()
}
