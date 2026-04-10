import XCTest
@testable import DockPilot

final class RulesEngineTests: XCTestCase {
    func testResolveReturnsMatchedRule() {
        let app = AppDescriptor(
            bundleIdentifier: "com.example.demo",
            localizedName: "Demo",
            processIdentifier: 1,
            isHidden: false,
            isFrontmost: false,
            activationPolicy: "regular",
            launchDate: nil
        )
        let rule = UserRule(bundleIdentifier: "com.example.demo", appName: "Demo", isExcluded: true)

        let resolution = RulesEngine().resolve(for: app, settings: .default, rules: [rule])

        XCTAssertEqual(resolution.rule?.bundleIdentifier, "com.example.demo")
        XCTAssertTrue(resolution.isExcluded)
    }
}
