import Combine
import Foundation

@MainActor
final class RecentAppsStore: ObservableObject {
    @Published private(set) var bundleIdentifiers: [String]

    private let defaults: UserDefaults
    private let key = "DockPilot.recentApps"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.bundleIdentifiers = defaults.stringArray(forKey: key) ?? []
    }

    func record(bundleIdentifier: String) {
        bundleIdentifiers.removeAll { $0 == bundleIdentifier }
        bundleIdentifiers.insert(bundleIdentifier, at: 0)
        bundleIdentifiers = Array(bundleIdentifiers.prefix(20))
        defaults.set(bundleIdentifiers, forKey: key)
    }
}
