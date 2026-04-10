import Foundation

struct UserRule: Codable, Hashable, Identifiable, Sendable {
    var id: UUID
    var bundleIdentifier: String
    var appName: String
    var isEnabled: Bool
    var isExcluded: Bool
    var preferredDockAction: ActionType?
    var multiWindowPolicy: MultiWindowPolicy?
    var gestureOverrides: [GestureKind: ActionType]
    var preferredSnap: SnapPreference
    var enableFallbackMode: Bool

    init(
        id: UUID = UUID(),
        bundleIdentifier: String,
        appName: String,
        isEnabled: Bool = true,
        isExcluded: Bool = false,
        preferredDockAction: ActionType? = nil,
        multiWindowPolicy: MultiWindowPolicy? = nil,
        gestureOverrides: [GestureKind: ActionType] = [:],
        preferredSnap: SnapPreference = .inherit,
        enableFallbackMode: Bool = false
    ) {
        self.id = id
        self.bundleIdentifier = bundleIdentifier
        self.appName = appName
        self.isEnabled = isEnabled
        self.isExcluded = isExcluded
        self.preferredDockAction = preferredDockAction
        self.multiWindowPolicy = multiWindowPolicy
        self.gestureOverrides = gestureOverrides
        self.preferredSnap = preferredSnap
        self.enableFallbackMode = enableFallbackMode
    }
}
