import Foundation

struct RulesResolution: Hashable, Sendable {
    var rule: UserRule?
    var isExcluded: Bool
    var preferredMultiWindowPolicy: MultiWindowPolicy
}

struct RulesEngine {
    private let matcher = RuleMatcher()

    func resolve(for app: AppDescriptor, settings: DockPilotSettings, rules: [UserRule]) -> RulesResolution {
        let matchedRule = matcher.matchRule(for: app, rules: rules)
        return RulesResolution(
            rule: matchedRule,
            isExcluded: matchedRule?.isExcluded ?? false,
            preferredMultiWindowPolicy: matchedRule?.multiWindowPolicy ?? settings.dockBehavior.multiWindowPolicy
        )
    }

    func action(for gesture: GestureKind, app: AppDescriptor, settings: DockPilotSettings, rules: [UserRule]) -> ActionType? {
        let matchedRule = matcher.matchRule(for: app, rules: rules)
        if let override = matchedRule?.gestureOverrides[gesture] {
            return override
        }

        return settings.gestureDefinitions.first(where: { $0.kind == gesture && $0.isEnabled })?.action
    }
}
