import Foundation

enum DefaultRules {
    static let seedRules: [UserRule] = [
        UserRule(
            bundleIdentifier: "com.apple.finder",
            appName: "Finder",
            preferredDockAction: .activateApp,
            multiWindowPolicy: .frontWindowOnly,
            enableFallbackMode: true
        )
    ]
}
