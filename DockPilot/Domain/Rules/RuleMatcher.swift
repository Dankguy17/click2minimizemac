import Foundation

struct RuleMatcher {
    func matchRule(for app: AppDescriptor, rules: [UserRule]) -> UserRule? {
        rules.first { rule in
            rule.isEnabled && rule.bundleIdentifier == app.bundleIdentifier
        }
    }
}
