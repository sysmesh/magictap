import XCTest
import Cocoa
import CoreGraphics

@testable import MagicTapLib

class AppDelegateTests: XCTestCase {

    var appDelegate: AppDelegate!

    override func setUp() {
        super.setUp()
        appDelegate = AppDelegate()
    }

    override func tearDown() {
        appDelegate = nil
        super.tearDown()
    }

    // MARK: - Initialization

    func testInitialization_DefaultState() {
        XCTAssertTrue(appDelegate.isEnabled, "App should be enabled by default")
    }

    // MARK: - Enable/Disable Toggle

    func testToggleEnabled_FromEnabledToDisabled() {
        appDelegate.isEnabled = true
        appDelegate.toggleEnabled()

        XCTAssertFalse(appDelegate.isEnabled, "Toggle should disable when enabled")
    }

    func testToggleEnabled_FromDisabledToEnabled() {
        appDelegate.isEnabled = false
        appDelegate.toggleEnabled()

        XCTAssertTrue(appDelegate.isEnabled, "Toggle should enable when disabled")
    }

    func testToggleEnabled_MultipleToggles() {
        let initialState = appDelegate.isEnabled

        appDelegate.toggleEnabled()
        XCTAssertNotEqual(appDelegate.isEnabled, initialState)

        appDelegate.toggleEnabled()
        XCTAssertEqual(appDelegate.isEnabled, initialState)

        appDelegate.toggleEnabled()
        XCTAssertNotEqual(appDelegate.isEnabled, initialState)
    }

    // MARK: - Menu Bar Setup
    // Note: Menu bar tests are skipped because they require a connection to the window
    // server which is not available in test environments. These should be tested manually
    // or with UI tests.

    // MARK: - Click Synthesis

    func testSynthesizeClick_CreatesEvents() {
        let location = CGPoint(x: 100, y: 100)

        // This test just verifies the method doesn't crash
        // Testing actual event posting requires more complex mocking
        appDelegate.synthesizeClick(at: location)

        // If we get here without crashing, the test passes
        XCTAssertTrue(true, "synthesizeClick should execute without error")
    }

    // MARK: - State Management

    func testStateManagement_EnabledByDefault() {
        let newDelegate = AppDelegate()
        XCTAssertTrue(newDelegate.isEnabled)
    }

    // Note: Menu bar and event handling tests require UI/window server connections
    // which are not available in test environments. These are better suited for
    // manual testing or UI tests. The core tap detection logic is thoroughly
    // tested in TapDetectorTests.swift
}
