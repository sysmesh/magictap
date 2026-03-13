import Foundation
import CoreGraphics
import AppKit

// Swift wrapper for Multitouch framework
class MultitouchManager {
    private var devices: [MTDeviceRef] = []
    private var tapDetector = TapDetector(tapTimeThreshold: 0.85, tapMovementThreshold: 0.08) // Was 0.25 and 0.08
    private var isEnabled = true
    private var activeTouch: Int32 = -1
    private var touchStartX: Float = 0.0
    private var touchStartY: Float = 0.0
    private var rightClickThreshold: Float = 0.6  // X > 0.6 = right side
    private var surfaceMovementThreshold: Float = 0.15  // Max finger movement on surface (0-1 scale)
    private var isDragging = false  // Track if double-tap drag is in progress
    private var dragStartCursorPos: CGPoint = .zero  // Cursor position when drag started
    private var dragLastTouchX: Float = 0.0  // Last touch position on surface
    private var dragLastTouchY: Float = 0.0

    fileprivate static var sharedInstance: MultitouchManager?

    var onClickSynthesized: ((CGPoint, Bool) -> Void)?
    var onDragStarted: ((CGPoint) -> Void)?
    var onDragMoved: ((CGPoint, CGPoint) -> Void)?  // (newPosition, delta)
    var onDragEnded: ((CGPoint) -> Void)?

    init() {
        MultitouchManager.sharedInstance = self
    }

    // Expose tap sensitivity parameters for UI controls
    var tapTimeThreshold: TimeInterval {
        get { return tapDetector.tapTimeThreshold }
        set { tapDetector.tapTimeThreshold = newValue }
    }

    var tapMovementThreshold: CGFloat {
        get { return tapDetector.tapMovementThreshold }
        set { tapDetector.tapMovementThreshold = newValue }
    }

    func start() {
        guard let deviceList = MTDeviceCreateList() else {
            return
        }

        let deviceArray = deviceList.takeRetainedValue() as NSArray
        let count = CFArrayGetCount(deviceArray)

        for i in 0..<count {
            let device = unsafeBitCast(CFArrayGetValueAtIndex(deviceArray, i), to: MTDeviceRef.self)

            // Only monitor external devices (Magic Mouse), skip built-in trackpads
            let isBuiltIn = MTDeviceIsBuiltIn(device)

            if !isBuiltIn {
                devices.append(device)
                MTRegisterContactFrameCallback(device, touchCallback)
                MTDeviceStart(device, 0)
            }
        }
    }

    func stop() {
        for device in devices {
            MTUnregisterContactFrameCallback(device, touchCallback)
            MTDeviceStop(device)
        }
        devices.removeAll()
    }

    func setEnabled(_ enabled: Bool) {
        isEnabled = enabled
    }

    func processTouches(_ touches: UnsafeMutablePointer<MTTouch>, numTouches: Int, timestamp: Double) {
        guard isEnabled else { return }

        if numTouches == 0 {
            if activeTouch != -1 || isDragging {
                // Get cursor position directly from CGEvent (already in correct coordinate space)
                let cgLocation = CGEvent(source: nil)?.location ?? CGPoint.zero
                let isLeftClick = touchStartX <= rightClickThreshold

                // If drag was in progress and touch ended, release the mouse button
                if isDragging {
                    onDragEnded?(cgLocation)
                    isDragging = false
                    dragStartCursorPos = .zero
                } else {
                    // Normal tap ended - check if it's a valid tap
                    let result = tapDetector.touchEnded(at: cgLocation, isLeftSide: isLeftClick)
                    
                    switch result {
                    case .doubleTap:
                        // Double tap with both lifts - treat as normal click for now
                        onClickSynthesized?(cgLocation, !isLeftClick)
                    case .singleTap(let location):
                        onClickSynthesized?(location, !isLeftClick)
                    case .none:
                        break
                    }
                }
                
                activeTouch = -1
                touchStartX = 0.0
                touchStartY = 0.0
                dragLastTouchX = 0.0
                dragLastTouchY = 0.0
            }
            return
        }

        if numTouches == 1 {
            let touch = touches[0]
            // Get cursor position directly from CGEvent (already in correct coordinate space)
            let cgLocation = CGEvent(source: nil)?.location ?? CGPoint.zero
            let isLeftSide = touch.normalized.position.x <= rightClickThreshold

            // If we're dragging and this is our touch, always send drag events
            if isDragging && activeTouch == touch.identifier {
                // Get current cursor position - it's already moving with the finger
                let currentPos = CGEvent(source: nil)?.location ?? .zero
                
                onDragMoved?(currentPos, currentPos)
                
                // Update tracking position
                dragLastTouchX = touch.normalized.position.x
                dragLastTouchY = touch.normalized.position.y
            }
            // Touch state 4 = touch began
            else if touch.state == 4 {
                if activeTouch == -1 && !isDragging {
                    // New touch started - check if this should start a drag hold
                    if tapDetector.shouldStartDragHold(at: cgLocation, isLeftSide: isLeftSide) {
                        // Start drag (hold mouse button)
                        isDragging = true
                        activeTouch = touch.identifier
                        touchStartX = touch.normalized.position.x
                        touchStartY = touch.normalized.position.y
                        dragStartCursorPos = cgLocation
                        dragLastTouchX = touch.normalized.position.x
                        dragLastTouchY = touch.normalized.position.y
                        onDragStarted?(cgLocation)
                    } else {
                        // Regular touch - start tracking
                        activeTouch = touch.identifier
                        touchStartX = touch.normalized.position.x
                        touchStartY = touch.normalized.position.y
                        tapDetector.touchBegan(at: cgLocation)
                    }
                }
            } else if activeTouch == touch.identifier && !isDragging {
                // Touch moved - for non-drag tracking
                // Check if finger moved too much on surface (scrolling)
                let deltaX = abs(touch.normalized.position.x - touchStartX)
                let deltaY = abs(touch.normalized.position.y - touchStartY)
                let surfaceMovement = max(deltaX, deltaY)

                if surfaceMovement > surfaceMovementThreshold {
                    // Finger moved too much on surface - likely scrolling, cancel tap
                    tapDetector.reset()
                    tapDetector.clearDoubleTapState()
                    activeTouch = -1
                    touchStartX = 0.0
                    touchStartY = 0.0
                } else {
                    // Check cursor movement too
                    let moved = tapDetector.touchMoved(to: cgLocation)
                    if moved {
                        activeTouch = -1
                        touchStartX = 0.0
                        touchStartY = 0.0
                    }
                }
            }
        } else if numTouches > 1 {
            if activeTouch != -1 || isDragging {
                tapDetector.reset()
                tapDetector.clearDoubleTapState()
                if isDragging {
                    let currentLoc = CGEvent(source: nil)?.location ?? CGPoint.zero
                    onDragEnded?(currentLoc)
                    isDragging = false
                }
                activeTouch = -1
                touchStartX = 0.0
                touchStartY = 0.0
            }
        }
    }

    deinit {
        stop()
    }
}

private func touchCallback(device: Int32, touches: UnsafeMutablePointer<MTTouch>?, numTouches: Int32, timestamp: Double, frame: Int32) -> Int32 {
    if let manager = MultitouchManager.sharedInstance, let touches = touches {
        manager.processTouches(touches, numTouches: Int(numTouches), timestamp: timestamp)
    }
    return 0
}
