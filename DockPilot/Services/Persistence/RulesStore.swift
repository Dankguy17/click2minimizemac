import Combine
import Foundation

@MainActor
final class RulesStore: ObservableObject {
    @Published var rules: [UserRule] {
        didSet {
            persist(rules)
        }
    }

    private let defaults: UserDefaults
    private let key = "DockPilot.rules"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if let data = defaults.data(forKey: key),
           let decoded = try? PropertyListDecoder().decode([UserRule].self, from: data) {
            self.rules = decoded
        } else {
            self.rules = DefaultRules.seedRules
            persist(self.rules)
        }
    }

    func upsert(_ rule: UserRule) {
        if let index = rules.firstIndex(where: { $0.id == rule.id }) {
            rules[index] = rule
        } else {
            rules.append(rule)
        }
    }

    func remove(_ rule: UserRule) {
        rules.removeAll { $0.id == rule.id }
    }

    private func persist(_ rules: [UserRule]) {
        guard let data = try? PropertyListEncoder().encode(rules) else { return }
        defaults.set(data, forKey: key)
    }
}
