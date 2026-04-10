import Combine
import Foundation

@MainActor
final class SettingsStore: ObservableObject {
    @Published var settings: DockPilotSettings {
        didSet {
            persist(settings)
        }
    }

    private let defaults: UserDefaults
    private let key = "DockPilot.settings"
    private let migrationService = MigrationService()

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.settings = Self.loadSettings(defaults: defaults)
        self.settings = migrationService.migrate(settings)
        persist(self.settings)
    }

    func reset() {
        settings = DockPilotSettings.default
    }

    private func persist(_ settings: DockPilotSettings) {
        guard let data = try? PropertyListEncoder().encode(settings) else { return }
        defaults.set(data, forKey: key)
    }

    private static func loadSettings(defaults: UserDefaults) -> DockPilotSettings {
        if let data = defaults.data(forKey: "DockPilot.settings"),
           let decoded = try? PropertyListDecoder().decode(DockPilotSettings.self, from: data) {
            return decoded
        }

        guard let url = Bundle.main.url(forResource: "DefaultSettings", withExtension: "plist"),
              let data = try? Data(contentsOf: url),
              let decoded = try? PropertyListDecoder().decode(DockPilotSettings.self, from: data) else {
            return .default
        }

        return decoded
    }
}
