import XCTest
@testable import DockPilot

final class ActionPlannerTests: XCTestCase {
    func testFrontmostVisibleDockToggleMinimizes() {
        let planner = ActionPlanner()
        let appState = Self.makeState(classification: .activeVisible)

        let plan = planner.planDockToggle(for: appState, settings: .default, matchedRule: nil)

        XCTAssertEqual(plan.steps.first?.action, .minimizeAllWindows)
    }

    func testHiddenDockToggleUnhides() {
        let planner = ActionPlanner()
        let appState = Self.makeState(classification: .backgroundHidden)

        let plan = planner.planDockToggle(for: appState, settings: .default, matchedRule: nil)

        XCTAssertEqual(plan.steps.map(\.action), [.unhideApp, .bringAllToFront])
    }

    func testMinimizedDockToggleRestores() {
        let planner = ActionPlanner()
        let appState = Self.makeState(classification: .backgroundMinimized)

        let plan = planner.planDockToggle(for: appState, settings: .default, matchedRule: nil)

        XCTAssertEqual(plan.steps.first?.action, .restoreAllWindows)
    }

    private static func makeState(classification: AppStateClassification) -> AppState {
        let app = AppDescriptor(
            bundleIdentifier: "com.example.test",
            localizedName: "Test",
            processIdentifier: 1,
            isHidden: classification == .backgroundHidden || classification == .activeHidden,
            isFrontmost: classification == .activeVisible || classification == .activeMinimized || classification == .activeHidden,
            activationPolicy: "regular",
            launchDate: nil
        )
        let window = WindowDescriptor(
            id: "window",
            title: "Window",
            appBundleIdentifier: app.bundleIdentifier,
            ownerProcessIdentifier: 1,
            frame: CGRect(x: 0, y: 0, width: 500, height: 400),
            isMain: true,
            isKey: true,
            isMinimized: classification == .backgroundMinimized || classification == .activeMinimized,
            isVisible: classification == .activeVisible || classification == .backgroundVisible,
            isFullscreen: false,
            isStandardWindow: true,
            role: nil,
            subrole: nil
        )
        return AppState(
            app: app,
            classification: classification,
            confidence: 1,
            reason: "Test",
            actionableWindows: [window],
            hiddenWindowCount: 0,
            minimizedWindowCount: window.isMinimized ? 1 : 0,
            visibleWindowCount: window.isVisible ? 1 : 0,
            lastFocusedWindowID: window.id,
            isStageManagerAffected: false
        )
    }
}
