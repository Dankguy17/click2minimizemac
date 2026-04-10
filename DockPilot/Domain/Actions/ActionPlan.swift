import Foundation

struct ActionPlan: Codable, Hashable, Sendable {
    struct Step: Codable, Hashable, Identifiable, Sendable {
        var id: UUID
        var action: ActionType
        var targetWindowIDs: [String]

        init(id: UUID = UUID(), action: ActionType, targetWindowIDs: [String] = []) {
            self.id = id
            self.action = action
            self.targetWindowIDs = targetWindowIDs
        }
    }

    var source: ActionSource
    var targetBundleIdentifier: String
    var steps: [Step]
    var reason: String
    var requiresFallback: Bool

    static func noOp(for app: AppDescriptor, source: ActionSource, reason: String) -> ActionPlan {
        ActionPlan(
            source: source,
            targetBundleIdentifier: app.bundleIdentifier,
            steps: [.init(action: .noOp)],
            reason: reason,
            requiresFallback: false
        )
    }
}
