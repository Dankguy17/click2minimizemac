import Foundation

enum AppStateClassification: String, Codable, CaseIterable, Hashable, Identifiable {
    case activeVisible
    case activeMinimized
    case activeHidden
    case backgroundVisible
    case backgroundMinimized
    case backgroundHidden
    case mixed
    case unknown

    var id: String { rawValue }
}

struct AppState: Codable, Hashable, Sendable {
    var app: AppDescriptor
    var classification: AppStateClassification
    var confidence: Double
    var reason: String
    var actionableWindows: [WindowDescriptor]
    var hiddenWindowCount: Int
    var minimizedWindowCount: Int
    var visibleWindowCount: Int
    var lastFocusedWindowID: String?
    var isStageManagerAffected: Bool

    static func unknown(for app: AppDescriptor, reason: String) -> AppState {
        AppState(
            app: app,
            classification: .unknown,
            confidence: 0.0,
            reason: reason,
            actionableWindows: [],
            hiddenWindowCount: 0,
            minimizedWindowCount: 0,
            visibleWindowCount: 0,
            lastFocusedWindowID: nil,
            isStageManagerAffected: false
        )
    }
}
