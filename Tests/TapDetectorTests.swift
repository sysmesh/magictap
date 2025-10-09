import XCTest
import Foundation
import CoreGraphics

@testable import MouseToucherLib

class TapDetectorTests: XCTestCase {

    var detector: TapDetector!

    override func setUp() {
        super.setUp()
        detector = TapDetector(tapTimeThreshold: 0.3, tapMovementThreshold: 5.0)
    }

    override func tearDown() {
        detector = nil
        super.tearDown()
    }

    // MARK: - Basic Tap Detection

    func testValidTap_WithinTimeAndMovementThreshold() {
        let startLocation = CGPoint(x: 100, y: 100)
        let endLocation = CGPoint(x: 102, y: 102) // 2.83 pixels away

        detector.touchBegan(at: startLocation)
        let result = detector.touchEnded(at: endLocation)

        XCTAssertNotNil(result, "Valid tap should return a location")
        XCTAssertEqual(result?.x, endLocation.x)
        XCTAssertEqual(result?.y, endLocation.y)
    }

    func testValidTap_NoMovement() {
        let location = CGPoint(x: 100, y: 100)

        detector.touchBegan(at: location)
        let result = detector.touchEnded(at: location)

        XCTAssertNotNil(result, "Tap with no movement should be valid")
        XCTAssertEqual(result, location)
    }

    func testInvalidTap_ExceedsMovementThreshold() {
        let startLocation = CGPoint(x: 100, y: 100)
        let endLocation = CGPoint(x: 110, y: 110) // 14.14 pixels away

        detector.touchBegan(at: startLocation)
        let result = detector.touchEnded(at: endLocation)

        XCTAssertNil(result, "Tap exceeding movement threshold should be invalid")
    }

    func testInvalidTap_ExceedsTimeThreshold() {
        let startLocation = CGPoint(x: 100, y: 100)

        detector.touchBegan(at: startLocation)

        // Wait longer than threshold
        Thread.sleep(forTimeInterval: 0.35)

        let result = detector.touchEnded(at: startLocation)

        XCTAssertNil(result, "Tap exceeding time threshold should be invalid")
    }

    func testTapAtBoundary_MovementThreshold() {
        let startLocation = CGPoint(x: 100, y: 100)
        let endLocation = CGPoint(x: 104.9, y: 100) // Just under 5 pixels

        detector.touchBegan(at: startLocation)
        let result = detector.touchEnded(at: endLocation)

        XCTAssertNotNil(result, "Tap just within movement threshold should be valid")
    }

    func testTapJustOverBoundary_MovementThreshold() {
        let startLocation = CGPoint(x: 100, y: 100)
        let endLocation = CGPoint(x: 105.1, y: 100) // Just over 5 pixels

        detector.touchBegan(at: startLocation)
        let result = detector.touchEnded(at: endLocation)

        XCTAssertNil(result, "Tap just over movement threshold should be invalid")
    }

    // MARK: - Touch Movement Detection

    func testTouchMoved_WithinThreshold() {
        let startLocation = CGPoint(x: 100, y: 100)
        let moveLocation = CGPoint(x: 102, y: 102)

        detector.touchBegan(at: startLocation)
        let exceededThreshold = detector.touchMoved(to: moveLocation)

        XCTAssertFalse(exceededThreshold, "Small movement should not exceed threshold")
        XCTAssertTrue(detector.isTracking, "Detector should still be tracking")
    }

    func testTouchMoved_ExceedsThreshold() {
        let startLocation = CGPoint(x: 100, y: 100)
        let moveLocation = CGPoint(x: 110, y: 110)

        detector.touchBegan(at: startLocation)
        let exceededThreshold = detector.touchMoved(to: moveLocation)

        XCTAssertTrue(exceededThreshold, "Large movement should exceed threshold")
        XCTAssertFalse(detector.isTracking, "Detector should stop tracking after threshold exceeded")
    }

    func testTouchMoved_AfterExceedingThreshold_ShouldInvalidateTap() {
        let startLocation = CGPoint(x: 100, y: 100)
        let moveLocation = CGPoint(x: 110, y: 110)

        detector.touchBegan(at: startLocation)
        _ = detector.touchMoved(to: moveLocation)
        let result = detector.touchEnded(at: startLocation)

        XCTAssertNil(result, "Tap should be invalid after movement exceeded threshold")
    }

    // MARK: - State Management

    func testReset_ClearsTrackingState() {
        let location = CGPoint(x: 100, y: 100)

        detector.touchBegan(at: location)
        XCTAssertTrue(detector.isTracking)

        detector.reset()
        XCTAssertFalse(detector.isTracking)

        let result = detector.touchEnded(at: location)
        XCTAssertNil(result, "Should not detect tap after reset")
    }

    func testTouchEnded_ResetsState() {
        let location = CGPoint(x: 100, y: 100)

        detector.touchBegan(at: location)
        XCTAssertTrue(detector.isTracking)

        _ = detector.touchEnded(at: location)
        XCTAssertFalse(detector.isTracking, "State should be reset after touch ended")
    }

    func testIsTracking_InitiallyFalse() {
        XCTAssertFalse(detector.isTracking, "Detector should not be tracking initially")
    }

    func testIsTracking_TrueAfterTouchBegan() {
        detector.touchBegan(at: CGPoint(x: 100, y: 100))
        XCTAssertTrue(detector.isTracking, "Detector should be tracking after touch began")
    }

    // MARK: - Multiple Taps

    func testMultipleTaps_Sequential() {
        let location1 = CGPoint(x: 100, y: 100)
        let location2 = CGPoint(x: 200, y: 200)

        detector.touchBegan(at: location1)
        let result1 = detector.touchEnded(at: location1)
        XCTAssertNotNil(result1)

        detector.touchBegan(at: location2)
        let result2 = detector.touchEnded(at: location2)
        XCTAssertNotNil(result2)

        XCTAssertEqual(result1, location1)
        XCTAssertEqual(result2, location2)
    }

    func testInvalidTap_FollowedByValidTap() {
        let location = CGPoint(x: 100, y: 100)

        // Invalid tap (too long)
        detector.touchBegan(at: location)
        Thread.sleep(forTimeInterval: 0.35)
        let result1 = detector.touchEnded(at: location)
        XCTAssertNil(result1)

        // Valid tap
        detector.touchBegan(at: location)
        let result2 = detector.touchEnded(at: location)
        XCTAssertNotNil(result2)
    }

    // MARK: - Edge Cases

    func testTouchEnded_WithoutTouchBegan() {
        let location = CGPoint(x: 100, y: 100)
        let result = detector.touchEnded(at: location)

        XCTAssertNil(result, "Should not detect tap without touchBegan")
    }

    func testTouchMoved_WithoutTouchBegan() {
        let location = CGPoint(x: 100, y: 100)
        let exceededThreshold = detector.touchMoved(to: location)

        XCTAssertFalse(exceededThreshold, "Should handle touchMoved without touchBegan")
    }

    func testMultipleTouchBegan_WithoutEnding() {
        let location1 = CGPoint(x: 100, y: 100)
        let location2 = CGPoint(x: 200, y: 200)

        detector.touchBegan(at: location1)
        detector.touchBegan(at: location2) // Replaces previous

        let result = detector.touchEnded(at: location2)
        XCTAssertNotNil(result, "Should handle multiple touchBegan calls")
    }

    // MARK: - Custom Thresholds

    func testCustomThresholds_StrictTime() {
        let strictDetector = TapDetector(tapTimeThreshold: 0.1, tapMovementThreshold: 5.0)
        let location = CGPoint(x: 100, y: 100)

        strictDetector.touchBegan(at: location)
        Thread.sleep(forTimeInterval: 0.15)
        let result = strictDetector.touchEnded(at: location)

        XCTAssertNil(result, "Strict time threshold should reject slower taps")
    }

    func testCustomThresholds_StrictMovement() {
        let strictDetector = TapDetector(tapTimeThreshold: 0.3, tapMovementThreshold: 2.0)
        let startLocation = CGPoint(x: 100, y: 100)
        let endLocation = CGPoint(x: 103, y: 100) // 3 pixels away

        strictDetector.touchBegan(at: startLocation)
        let result = strictDetector.touchEnded(at: endLocation)

        XCTAssertNil(result, "Strict movement threshold should reject taps with more movement")
    }

    func testCustomThresholds_RelaxedThresholds() {
        let relaxedDetector = TapDetector(tapTimeThreshold: 0.5, tapMovementThreshold: 10.0)
        let startLocation = CGPoint(x: 100, y: 100)
        let endLocation = CGPoint(x: 108, y: 100) // 8 pixels away

        relaxedDetector.touchBegan(at: startLocation)
        Thread.sleep(forTimeInterval: 0.4)
        let result = relaxedDetector.touchEnded(at: endLocation)

        XCTAssertNotNil(result, "Relaxed thresholds should accept slower/longer taps")
    }

    // MARK: - Performance

    func testPerformance_RapidTaps() {
        measure {
            for i in 0..<1000 {
                let location = CGPoint(x: CGFloat(i % 100), y: CGFloat(i / 100))
                detector.touchBegan(at: location)
                _ = detector.touchEnded(at: location)
            }
        }
    }
}
