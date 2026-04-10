import XCTest
@testable import DockPilot

final class GestureRoutingTests: XCTestCase {
    func testPerAppGestureOverrideWins() {
        let app = AppDescriptor(
            bundleIdentifier: "com.example.override",
            localizedName: "Override",
            processIdentifier: 10,
            isHidden: false,
            isFrontmost: true,
            activationPolicy: "regular",
            launchDate: nil
        )
        let rule = UserRule(
            bundleIdentifier: app.bundleIdentifier,
            appName: app.localizedName,
            gestureOverrides: [.rockerLeft: .fill]
        )

        let action = RulesEngine().action(for: .rockerLeft, app: app, settings: .default, rules: [rule])

        XCTAssertEqual(action, .fill)
    }
}
