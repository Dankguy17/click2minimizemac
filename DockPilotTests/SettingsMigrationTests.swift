import XCTest
@testable import DockPilot

final class SettingsMigrationTests: XCTestCase {
    func testMigrationUpgradesSchemaAndSeedsGestures() {
        var legacy = DockPilotSettings.default
        legacy.schemaVersion = 0
        legacy.gestureDefinitions = []

        let migrated = MigrationService().migrate(legacy)

        XCTAssertEqual(migrated.schemaVersion, 1)
        XCTAssertFalse(migrated.gestureDefinitions.isEmpty)
    }
}
