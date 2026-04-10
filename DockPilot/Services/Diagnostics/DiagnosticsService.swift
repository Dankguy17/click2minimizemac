import Combine
import Foundation

struct DiagnosticsSnapshot: Hashable, Sendable {
    var accessibilityTrusted: Bool
    var eventTapEnabled: Bool
    var frontmostAppName: String
    var frontmostBundleIdentifier: String
    var resolvedState: AppStateClassification
    var windowCount: Int
    var plannedAction: String
    var executedAction: String
    var fallbackUsed: Bool
    var lastError: String
    var lastInputEvent: String

    static let empty = DiagnosticsSnapshot(
        accessibilityTrusted: false,
        eventTapEnabled: false,
        frontmostAppName: "Unknown",
        frontmostBundleIdentifier: "",
        resolvedState: .unknown,
        windowCount: 0,
        plannedAction: "None",
        executedAction: "None",
        fallbackUsed: false,
        lastError: "None",
        lastInputEvent: "None"
    )
}

@MainActor
final class DiagnosticsService: ObservableObject {
    @Published private(set) var snapshot: DiagnosticsSnapshot = .empty
    @Published private(set) var recentResults: [ExecutionResult] = []

    func update(
        accessibilityTrusted: Bool? = nil,
        eventTapEnabled: Bool? = nil,
        frontmostAppName: String? = nil,
        frontmostBundleIdentifier: String? = nil,
        resolvedState: AppStateClassification? = nil,
        windowCount: Int? = nil,
        plannedAction: String? = nil,
        executedAction: String? = nil,
        fallbackUsed: Bool? = nil,
        lastError: String? = nil,
        lastInputEvent: String? = nil
    ) {
        snapshot = DiagnosticsSnapshot(
            accessibilityTrusted: accessibilityTrusted ?? snapshot.accessibilityTrusted,
            eventTapEnabled: eventTapEnabled ?? snapshot.eventTapEnabled,
            frontmostAppName: frontmostAppName ?? snapshot.frontmostAppName,
            frontmostBundleIdentifier: frontmostBundleIdentifier ?? snapshot.frontmostBundleIdentifier,
            resolvedState: resolvedState ?? snapshot.resolvedState,
            windowCount: windowCount ?? snapshot.windowCount,
            plannedAction: plannedAction ?? snapshot.plannedAction,
            executedAction: executedAction ?? snapshot.executedAction,
            fallbackUsed: fallbackUsed ?? snapshot.fallbackUsed,
            lastError: lastError ?? snapshot.lastError,
            lastInputEvent: lastInputEvent ?? snapshot.lastInputEvent
        )
    }

    func record(_ result: ExecutionResult) {
        recentResults.insert(result, at: 0)
        recentResults = Array(recentResults.prefix(50))
        update(
            executedAction: result.action.label,
            fallbackUsed: result.usedFallback,
            lastError: result.status == .failure ? result.message : "None"
        )
    }
}
