import Foundation

struct MigrationService {
    let currentSchemaVersion = 1

    func migrate(_ settings: DockPilotSettings) -> DockPilotSettings {
        if settings.schemaVersion >= currentSchemaVersion {
            return settings
        }

        var upgraded = settings
        upgraded.schemaVersion = currentSchemaVersion
        if upgraded.gestureDefinitions.isEmpty {
            upgraded.gestureDefinitions = GestureDefinition.defaults
        }
        return upgraded
    }
}
