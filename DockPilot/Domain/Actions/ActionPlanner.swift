import Foundation

struct ActionPlanner {
    func planDockToggle(
        for appState: AppState,
        settings: DockPilotSettings,
        matchedRule: UserRule?
    ) -> ActionPlan {
        if matchedRule?.isExcluded == true {
            return .noOp(for: appState.app, source: .dockClick, reason: "App excluded by rule")
        }

        if let preferredDockAction = matchedRule?.preferredDockAction, preferredDockAction != .dockSemanticToggle {
            return ActionPlan(
                source: .dockClick,
                targetBundleIdentifier: appState.app.bundleIdentifier,
                steps: [.init(action: preferredDockAction, targetWindowIDs: targetWindows(for: appState, policy: matchedRule?.multiWindowPolicy ?? settings.dockBehavior.multiWindowPolicy))],
                reason: "Rule override for dock action",
                requiresFallback: matchedRule?.enableFallbackMode ?? false
            )
        }

        let policy = matchedRule?.multiWindowPolicy ?? settings.dockBehavior.multiWindowPolicy

        switch appState.classification {
        case .activeVisible:
            return ActionPlan(
                source: .dockClick,
                targetBundleIdentifier: appState.app.bundleIdentifier,
                steps: [.init(action: settings.dockBehavior.prefersHideOverMinimize ? .hideApp : .minimizeAllWindows, targetWindowIDs: targetWindows(for: appState, policy: policy))],
                reason: "Frontmost visible app should get out of the way",
                requiresFallback: false
            )
        case .activeMinimized, .backgroundMinimized:
            let action: ActionType = policy == .lastFocusedWindow ? .restoreLastFocusedWindow : .restoreAllWindows
            return ActionPlan(
                source: .dockClick,
                targetBundleIdentifier: appState.app.bundleIdentifier,
                steps: [.init(action: action, targetWindowIDs: targetWindows(for: appState, policy: policy)), .init(action: .activateApp)],
                reason: "Restoring minimized windows",
                requiresFallback: false
            )
        case .activeHidden, .backgroundHidden:
            return ActionPlan(
                source: .dockClick,
                targetBundleIdentifier: appState.app.bundleIdentifier,
                steps: [.init(action: .unhideApp), .init(action: .bringAllToFront)],
                reason: "Unhiding app before bringing windows forward",
                requiresFallback: false
            )
        case .backgroundVisible:
            return ActionPlan(
                source: .dockClick,
                targetBundleIdentifier: appState.app.bundleIdentifier,
                steps: [.init(action: .activateApp), .init(action: .bringAllToFront)],
                reason: "Background visible app should activate",
                requiresFallback: false
            )
        case .mixed:
            let shouldRestore = appState.minimizedWindowCount > 0
            let primaryAction: ActionType = shouldRestore ? .restoreAllWindows : .activateApp
            return ActionPlan(
                source: .dockClick,
                targetBundleIdentifier: appState.app.bundleIdentifier,
                steps: [.init(action: primaryAction, targetWindowIDs: targetWindows(for: appState, policy: policy)), .init(action: .bringAllToFront)],
                reason: "Mixed state needs the safest activation path",
                requiresFallback: shouldRestore && (matchedRule?.enableFallbackMode ?? false)
            )
        case .unknown:
            return ActionPlan(
                source: .dockClick,
                targetBundleIdentifier: appState.app.bundleIdentifier,
                steps: [.init(action: .activateApp)],
                reason: "Unknown state fell back to activation",
                requiresFallback: settings.dockBehavior.enableAppleScriptFallback
            )
        }
    }

    func planGesture(
        kind: GestureKind,
        appState: AppState,
        matchedRule: UserRule?,
        settings: DockPilotSettings
    ) -> ActionPlan {
        let definitions = settings.gestureDefinitions
        guard let definition = definitions.first(where: { $0.kind == kind && $0.isEnabled }) else {
            return .noOp(for: appState.app, source: .dockGesture, reason: "Gesture disabled")
        }

        let action = matchedRule?.gestureOverrides[kind] ?? definition.action
        if action == .dockSemanticToggle {
            return planDockToggle(for: appState, settings: settings, matchedRule: matchedRule)
        }

        return ActionPlan(
            source: definition.scope == .dock ? .dockGesture : .titleBarGesture,
            targetBundleIdentifier: appState.app.bundleIdentifier,
            steps: [.init(action: action, targetWindowIDs: targetWindows(for: appState, policy: matchedRule?.multiWindowPolicy ?? settings.dockBehavior.multiWindowPolicy))],
            reason: "Gesture matched \(definition.name)",
            requiresFallback: matchedRule?.enableFallbackMode ?? false
        )
    }

    private func targetWindows(for appState: AppState, policy: MultiWindowPolicy) -> [String] {
        switch policy {
        case .allWindows:
            return appState.actionableWindows.map(\.id)
        case .frontWindowOnly:
            return appState.actionableWindows.first.map { [$0.id] } ?? []
        case .lastFocusedWindow:
            if let lastFocusedWindowID = appState.lastFocusedWindowID {
                return [lastFocusedWindowID]
            }
            return appState.actionableWindows.first.map { [$0.id] } ?? []
        case .cycleInsteadOfMinimize:
            return appState.actionableWindows.first.map { [$0.id] } ?? []
        }
    }
}
