import Foundation
import CoreGraphics

/// Handles tap detection logic - separated for testability
class TapDetector {
    let tapTimeThreshold: TimeInterval
    let tapMovementThreshold: CGFloat

    private var touchStartTime: Date?
    private var touchStartLocation: CGPoint?

    init(tapTimeThreshold: TimeInterval = 0.3, tapMovementThreshold: CGFloat = 5.0) {
        self.tapTimeThreshold = tapTimeThreshold
        self.tapMovementThreshold = tapMovementThreshold
    }

    /// Records the start of a touch
    func touchBegan(at location: CGPoint) {
        touchStartTime = Date()
        touchStartLocation = location
    }

    /// Records movement during touch
    /// Returns true if movement exceeds threshold (not a tap)
    func touchMoved(to location: CGPoint) -> Bool {
        guard let startLocation = touchStartLocation else { return false }
        let distance = hypot(location.x - startLocation.x, location.y - startLocation.y)

        if distance > tapMovementThreshold {
            reset()
            return true
        }
        return false
    }

    /// Checks if touch ending qualifies as a tap
    /// Returns the tap location if it's a valid tap, nil otherwise
    func touchEnded(at location: CGPoint) -> CGPoint? {
        defer { reset() }

        guard let startTime = touchStartTime,
              let startLocation = touchStartLocation else {
            return nil
        }

        let duration = Date().timeIntervalSince(startTime)
        let distance = hypot(location.x - startLocation.x, location.y - startLocation.y)

        if duration < tapTimeThreshold && distance < tapMovementThreshold {
            return location
        }

        return nil
    }

    /// Resets tap detection state
    func reset() {
        touchStartTime = nil
        touchStartLocation = nil
    }

    /// Returns true if a touch is currently being tracked
    var isTracking: Bool {
        return touchStartTime != nil
    }
}
