import Foundation
import CoreGraphics

/// Handles tap detection logic - separated for testability
class TapDetector {
    var tapTimeThreshold: TimeInterval
    var tapMovementThreshold: CGFloat
    var doubleTapTimeThreshold: TimeInterval = 0.5

    private var touchStartTime: Date?
    private var touchStartLocation: CGPoint?
    private var lastTapTime: Date?
    private var lastTapLocation: CGPoint?

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

    /// Checks if a new touch should start a drag hold
    /// Returns true if this touch should hold (second tap without releasing)
    func shouldStartDragHold(at location: CGPoint, isLeftSide: Bool) -> Bool {
        guard let lastTime = lastTapTime else { return false }
        
        let timeSinceLastTap = Date().timeIntervalSince(lastTime)
        
        // Only start drag if:
        // 1. There was a recent tap (within double tap threshold)
        // 2. This tap is on the same side (left)
        // 3. We haven't already used this tap for a drag
        if timeSinceLastTap < doubleTapTimeThreshold && isLeftSide {
            // Clear the last tap so we don't use it again
            lastTapTime = nil
            lastTapLocation = nil
            return true
        }
        
        // If too much time has passed, clear the state
        if timeSinceLastTap > doubleTapTimeThreshold {
            lastTapTime = nil
            lastTapLocation = nil
        }
        
        return false
    }

    /// Checks if touch ending qualifies as a tap
    /// Returns the tap location if it's a valid tap, nil otherwise
    func touchEnded(at location: CGPoint, isLeftSide: Bool) -> TapResult {
        defer { reset() }

        guard let startTime = touchStartTime,
              let startLocation = touchStartLocation else {
            return .none
        }

        let duration = Date().timeIntervalSince(startTime)
        let distance = hypot(location.x - startLocation.x, location.y - startLocation.y)

        if duration < tapTimeThreshold && distance < tapMovementThreshold {
            let currentTime = Date()
            
            // Check if there's a recent tap that would make this a double tap
            if let lastTime = lastTapTime,
               let lastLoc = lastTapLocation {
                let timeSinceLastTap = currentTime.timeIntervalSince(lastTime)
                let distSinceLastTap = hypot(location.x - lastLoc.x, location.y - lastLoc.y)
                
                if timeSinceLastTap < doubleTapTimeThreshold && distSinceLastTap < tapMovementThreshold * 10 {
                    // This is a double tap (both fingers lifted) - clear state
                    lastTapTime = nil
                    lastTapLocation = nil
                    return .doubleTap(location)
                }
            }
            
            // Store this tap for potential drag-hold detection
            lastTapTime = currentTime
            lastTapLocation = location
            return .singleTap(location)
        }

        return .none
    }

    /// Resets tap detection state
    func reset() {
        touchStartTime = nil
        touchStartLocation = nil
    }

    /// Clears double-tap state (call after handling a double tap)
    func clearDoubleTapState() {
        lastTapTime = nil
        lastTapLocation = nil
    }

    /// Returns true if a touch is currently being tracked
    var isTracking: Bool {
        return touchStartTime != nil
    }
}

/// Result of a touch end event
enum TapResult {
    case none
    case singleTap(CGPoint)
    case doubleTap(CGPoint)
}
