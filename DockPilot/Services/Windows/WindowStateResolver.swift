import Foundation

struct WindowStateResolver {
    func resolve(
        app: AppDescriptor,
        windows: [WindowDescriptor],
        frontmostBundleIdentifier: String?,
        stageManagerEnabled: Bool
    ) -> AppState {
        let visibleWindows = windows.filter { $0.isVisible && !$0.isMinimized }
        let minimizedWindows = windows.filter(\.isMinimized)
        let hiddenWindows = windows.filter { !$0.isVisible && !$0.isMinimized }
        let isFrontmost = app.bundleIdentifier == frontmostBundleIdentifier

        let classification: AppStateClassification
        let reason: String

        if app.isHidden {
            classification = isFrontmost ? .activeHidden : .backgroundHidden
            reason = "App reports hidden state"
        } else if !visibleWindows.isEmpty && minimizedWindows.isEmpty {
            classification = isFrontmost ? .activeVisible : .backgroundVisible
            reason = "Visible windows available"
        } else if visibleWindows.isEmpty && !minimizedWindows.isEmpty {
            classification = isFrontmost ? .activeMinimized : .backgroundMinimized
            reason = "Only minimized windows available"
        } else if !visibleWindows.isEmpty && !minimizedWindows.isEmpty {
            classification = .mixed
            reason = "Visible and minimized windows coexist"
        } else if windows.isEmpty {
            classification = app.isHidden ? .backgroundHidden : .unknown
            reason = "No standard windows reported"
        } else {
            classification = .unknown
            reason = "No clear window state"
        }

        return AppState(
            app: app,
            classification: classification,
            confidence: confidence(for: classification, windows: windows),
            reason: reason,
            actionableWindows: windows.filter(\.isStandardWindow),
            hiddenWindowCount: hiddenWindows.count,
            minimizedWindowCount: minimizedWindows.count,
            visibleWindowCount: visibleWindows.count,
            lastFocusedWindowID: windows.first(where: { $0.isKey || $0.isMain })?.id ?? windows.first?.id,
            isStageManagerAffected: stageManagerEnabled && windows.contains(where: \.isFullscreen)
        )
    }

    private func confidence(for classification: AppStateClassification, windows: [WindowDescriptor]) -> Double {
        switch classification {
        case .unknown:
            return windows.isEmpty ? 0.3 : 0.45
        case .mixed:
            return 0.65
        default:
            return windows.isEmpty ? 0.5 : 0.9
        }
    }
}
