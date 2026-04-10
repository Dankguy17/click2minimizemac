import XCTest
@testable import DockPilot

final class SnapEngineTests: XCTestCase {
    func testLeftSnapUsesHalfWidthWithinBounds() {
        let engine = SnapEngine()
        let bounds = CGRect(x: 0, y: 0, width: 1440, height: 900)

        let frame = engine.targetFrame(
            for: CGRect(x: 10, y: 10, width: 700, height: 500),
            within: bounds,
            side: .left,
            padding: 10
        )

        XCTAssertEqual(frame.origin.x, 10, accuracy: 0.1)
        XCTAssertEqual(frame.width, 705, accuracy: 0.1)
        XCTAssertEqual(frame.height, 880, accuracy: 0.1)
    }

    func testFillSnapUsesInsetBounds() {
        let engine = SnapEngine()
        let bounds = CGRect(x: 0, y: 0, width: 1000, height: 600)

        let frame = engine.targetFrame(
            for: .zero,
            within: bounds,
            side: .fill,
            padding: 20
        )

        XCTAssertEqual(frame, CGRect(x: 20, y: 20, width: 960, height: 560))
    }
}
