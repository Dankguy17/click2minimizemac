import XCTest
@testable import DockPilot

final class AppStateResolverTests: XCTestCase {
    func testResolveActiveVisibleState() {
        let app = AppDescriptor(
            bundleIdentifier: "com.example.visible",
            localizedName: "Visible",
            processIdentifier: 2,
            isHidden: false,
            isFrontmost: true,
            activationPolicy: "regular",
            launchDate: nil
        )
        let window = WindowDescriptor(
            id: "w1",
            title: "Window",
            appBundleIdentifier: app.bundleIdentifier,
            ownerProcessIdentifier: 2,
            frame: CGRect(x: 0, y: 0, width: 800, height: 600),
            isMain: true,
            isKey: true,
            isMinimized: false,
            isVisible: true,
            isFullscreen: false,
            isStandardWindow: true,
            role: nil,
            subrole: nil
        )

        let state = WindowStateResolver().resolve(
            app: app,
            windows: [window],
            frontmostBundleIdentifier: app.bundleIdentifier,
            stageManagerEnabled: false
        )

        XCTAssertEqual(state.classification, .activeVisible)
        XCTAssertEqual(state.visibleWindowCount, 1)
    }

    func testResolveBackgroundMinimizedState() {
        let app = AppDescriptor(
            bundleIdentifier: "com.example.minimized",
            localizedName: "Minimized",
            processIdentifier: 3,
            isHidden: false,
            isFrontmost: false,
            activationPolicy: "regular",
            launchDate: nil
        )
        let window = WindowDescriptor(
            id: "w1",
            title: "Window",
            appBundleIdentifier: app.bundleIdentifier,
            ownerProcessIdentifier: 3,
            frame: CGRect(x: 0, y: 0, width: 400, height: 300),
            isMain: false,
            isKey: false,
            isMinimized: true,
            isVisible: false,
            isFullscreen: false,
            isStandardWindow: true,
            role: nil,
            subrole: nil
        )

        let state = WindowStateResolver().resolve(
            app: app,
            windows: [window],
            frontmostBundleIdentifier: "com.example.other",
            stageManagerEnabled: false
        )

        XCTAssertEqual(state.classification, .backgroundMinimized)
        XCTAssertEqual(state.minimizedWindowCount, 1)
    }
}
