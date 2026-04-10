import Foundation

enum ActionSource: String, Codable, CaseIterable, Hashable {
    case dockClick
    case dockGesture
    case titleBarGesture
    case notchGesture
    case menuBar
    case appSwitcher
    case keyboard
    case diagnostics
}

enum MultiWindowPolicy: String, Codable, CaseIterable, Hashable, Identifiable {
    case allWindows
    case frontWindowOnly
    case lastFocusedWindow
    case cycleInsteadOfMinimize

    var id: String { rawValue }

    var label: String {
        switch self {
        case .allWindows:
            return "All Windows"
        case .frontWindowOnly:
            return "Front Window Only"
        case .lastFocusedWindow:
            return "Last Focused Window"
        case .cycleInsteadOfMinimize:
            return "Cycle Instead Of Minimize"
        }
    }
}

enum SnapPreference: String, Codable, CaseIterable, Hashable, Identifiable {
    case inherit
    case left
    case right
    case fill

    var id: String { rawValue }
}
