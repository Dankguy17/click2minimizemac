import Foundation

struct StageManagerHeuristics {
    func isStageManagerEnabled() -> Bool {
        let value = CFPreferencesCopyAppValue("GloballyEnabled" as CFString, "com.apple.WindowManager" as CFString)
        return (value as? Bool) ?? false
    }

    func shouldDegrade(action: ActionType, appState: AppState, settings: DockPilotSettings) -> Bool {
        guard settings.dockBehavior.stageManagerCompatibilityMode, isStageManagerEnabled() else {
            return false
        }

        if appState.isStageManagerAffected {
            switch action {
            case .minimizeAllWindows, .restoreAllWindows, .bringAllToFront:
                return true
            default:
                return false
            }
        }

        return false
    }
}
