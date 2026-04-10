import Foundation

enum ActionType: String, Codable, CaseIterable, Hashable, Identifiable, Sendable {
    case dockSemanticToggle
    case activateApp
    case unhideApp
    case restoreAllWindows
    case restoreLastFocusedWindow
    case minimizeAllWindows
    case minimizeFrontWindow
    case hideApp
    case bringAllToFront
    case toggleFullscreen
    case snapLeft
    case snapRight
    case fill
    case restoreFrame
    case showSwitcherOverlay
    case cycleRecentApps
    case noOp

    var id: String { rawValue }

    var label: String {
        switch self {
        case .dockSemanticToggle:
            return "Dock Semantic Toggle"
        case .activateApp:
            return "Activate App"
        case .unhideApp:
            return "Unhide App"
        case .restoreAllWindows:
            return "Restore All Windows"
        case .restoreLastFocusedWindow:
            return "Restore Last Focused Window"
        case .minimizeAllWindows:
            return "Minimize All Windows"
        case .minimizeFrontWindow:
            return "Minimize Front Window"
        case .hideApp:
            return "Hide App"
        case .bringAllToFront:
            return "Bring All Windows Forward"
        case .toggleFullscreen:
            return "Toggle Fullscreen"
        case .snapLeft:
            return "Snap Left"
        case .snapRight:
            return "Snap Right"
        case .fill:
            return "Fill Screen"
        case .restoreFrame:
            return "Restore Frame"
        case .showSwitcherOverlay:
            return "Show App Switcher"
        case .cycleRecentApps:
            return "Cycle Recent Apps"
        case .noOp:
            return "No-op"
        }
    }
}
