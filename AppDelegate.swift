import Cocoa
import ApplicationServices

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var multitouchManager: MultitouchManager?
    var isEnabled = true
    private var hasStartedMultitouch = false
    private var hasRequestedAccessibilityPrompt = false
    private var hasShownAccessibilityInstructions = false
    
    // UserDefaults key names
    private let timeThresholdKey = "TapTimeThreshold"
    private let movementThresholdKey = "TapMovementThreshold"

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupMenuBar()

        // Load saved preferences after menu is set up
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.loadSavedPreferences()
        }

        ensureAccessibilityAndStart()
    }

    @objc func showAccessibilityInstructions() {
        guard !hasShownAccessibilityInstructions else { return }
        hasShownAccessibilityInstructions = true
        let alert = NSAlert()
        alert.messageText = "Accessibility Permission Required"
        alert.informativeText = "Magic Tap needs accessibility permissions to simulate clicks.\n\nPlease grant permission in:\nSystem Settings > Privacy & Security > Accessibility\n\nAfter enabling, return to Magic Tap. The app will begin working as soon as permission is granted."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Open System Settings")
        alert.addButton(withTitle: "Quit")

        NSApp.activate(ignoringOtherApps: true)
        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!)
        } else if response == .alertSecondButtonReturn {
            NSApplication.shared.terminate(nil)
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        multitouchManager?.stop()
    }

    func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "computermouse.fill", accessibilityDescription: "Magic Tap")
        }

        let menu = NSMenu()

        let enabledItem = NSMenuItem(title: "Tap to Click: Enabled", action: #selector(toggleEnabled), keyEquivalent: "")
        enabledItem.state = isEnabled ? .on : .off
        menu.addItem(enabledItem)

        // Add sliders for tap sensitivity adjustment
        let sensitivityMenu = NSMenu()
        sensitivityMenu.title = "Tap Sensitivity"
        
        // Time Threshold Slider with proper margins and labels
        let timeTitleItem = NSMenuItem(title: "Time Threshold", action: nil, keyEquivalent: "")
        timeTitleItem.isEnabled = false
        sensitivityMenu.addItem(timeTitleItem)
        
        // Create container view for slider with labels
        let timeSliderContainer = NSView(frame: NSMakeRect(0, 0, 180, 20))
        
        let timeMinLabel = NSTextField(labelWithString: "Min")
        timeMinLabel.frame = NSMakeRect(0, 0, 25, 20)
        timeMinLabel.font = NSFont.systemFont(ofSize: 11)
        timeSliderContainer.addSubview(timeMinLabel)
        
        let timeSlider = NSSlider(value: 0.85, minValue: 0.0, maxValue: 2.0, target: self, action: #selector(timeSliderChanged(_:)))
        timeSlider.frame = NSMakeRect(28, 0, 120, 20)
        timeSliderContainer.addSubview(timeSlider)
        
        let timeMaxLabel = NSTextField(labelWithString: "Max")
        timeMaxLabel.frame = NSMakeRect(152, 0, 28, 20)
        timeMaxLabel.font = NSFont.systemFont(ofSize: 11)
        timeSliderContainer.addSubview(timeMaxLabel)
        
        let timeSliderItem = NSMenuItem(title: "", action: nil, keyEquivalent: "")
        timeSliderItem.view = timeSliderContainer
        sensitivityMenu.addItem(timeSliderItem)
        
        // Movement Threshold Slider with proper margins and labels
        let movementTitleItem = NSMenuItem(title: "Movement Threshold", action: nil, keyEquivalent: "")
        movementTitleItem.isEnabled = false
        sensitivityMenu.addItem(movementTitleItem)
        
        // Create container view for slider with labels
        let movementSliderContainer = NSView(frame: NSMakeRect(0, 0, 180, 20))
        
        let movementMinLabel = NSTextField(labelWithString: "Min")
        movementMinLabel.frame = NSMakeRect(0, 0, 25, 20)
        movementMinLabel.font = NSFont.systemFont(ofSize: 11)
        movementSliderContainer.addSubview(movementMinLabel)
        
        let movementSlider = NSSlider(value: 0.08, minValue: 0.0, maxValue: 10.0, target: self, action: #selector(movementSliderChanged(_:)))
        movementSlider.frame = NSMakeRect(28, 0, 120, 20)
        movementSliderContainer.addSubview(movementSlider)
        
        let movementMaxLabel = NSTextField(labelWithString: "Max")
        movementMaxLabel.frame = NSMakeRect(152, 0, 28, 20)
        movementMaxLabel.font = NSFont.systemFont(ofSize: 11)
        movementSliderContainer.addSubview(movementMaxLabel)
        
        let movementSliderItem = NSMenuItem(title: "", action: nil, keyEquivalent: "")
        movementSliderItem.view = movementSliderContainer
        sensitivityMenu.addItem(movementSliderItem)
        
        let sensitivityMenuItem = NSMenuItem(title: "Sensitivity", action: nil, keyEquivalent: "")
        sensitivityMenuItem.submenu = sensitivityMenu
        menu.addItem(sensitivityMenuItem)

        menu.addItem(NSMenuItem.separator())
        let accessibilityItem = NSMenuItem(title: "Accessibility Instructions…", action: #selector(showAccessibilityInstructions), keyEquivalent: "")
        accessibilityItem.target = self
        menu.addItem(accessibilityItem)

        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "About Magic Tap", action: #selector(showAbout), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit Magic Tap", action: #selector(quit), keyEquivalent: "q"))

        statusItem?.menu = menu
    }

    @objc func toggleEnabled() {
        isEnabled.toggle()
        if let menu = statusItem?.menu,
           let item = menu.items.first {
            item.state = isEnabled ? .on : .off
            item.title = isEnabled ? "Tap to Click: Enabled" : "Tap to Click: Disabled"
        }
        multitouchManager?.setEnabled(isEnabled)
    }

    @objc func timeSliderChanged(_ sender: NSSlider) {
        let value = Double(sender.floatValue)
        multitouchManager?.tapTimeThreshold = value
        savePreference(key: timeThresholdKey, value: value)
    }

    @objc func movementSliderChanged(_ sender: NSSlider) {
        let value = Double(sender.floatValue)
        multitouchManager?.tapMovementThreshold = CGFloat(value)
        savePreference(key: movementThresholdKey, value: value)
    }

    @objc func showAbout() {
        let alert = NSAlert()
        alert.messageText = "Magic Tap"
        alert.informativeText = """
        Tap-to-click for Magic Mouse

        • Tap left side for left click
        • Tap right side for right click

        Version 1.0

        Uses private MultitouchSupport framework
        """
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }

    @objc func quit() {
        multitouchManager?.stop()
        NSApplication.shared.terminate(nil)
    }

    private func loadSavedPreferences() {
        let defaults = UserDefaults.standard
        
        // Load saved time threshold with default of 0.85 if not found
        if let savedTimeThreshold = defaults.object(forKey: timeThresholdKey) as? Double {
            multitouchManager?.tapTimeThreshold = savedTimeThreshold
        }
        
        // Load saved movement threshold with default of 0.08 if not found
        if let savedMovementThreshold = defaults.object(forKey: movementThresholdKey) as? Double {
            multitouchManager?.tapMovementThreshold = CGFloat(savedMovementThreshold)
        }
    }

    private func savePreference(key: String, value: Double) {
        let defaults = UserDefaults.standard
        defaults.set(value, forKey: key)
    }

    private func ensureAccessibilityAndStart() {
        if AXIsProcessTrusted() {
            startMultitouchManager()
            return
        }

        requestAccessibilityPermissionIfNeeded()
        waitForAccessibilityPermission()
    }

    private func startMultitouchManager() {
        guard !hasStartedMultitouch else { return }
        hasStartedMultitouch = true

        multitouchManager = MultitouchManager()
        multitouchManager?.onClickSynthesized = { [weak self] location, isRightClick in
            self?.synthesizeClick(at: location, isRightClick: isRightClick)
        }
        multitouchManager?.start()
    }

    private func requestAccessibilityPermissionIfNeeded() {
        guard !hasRequestedAccessibilityPrompt else { return }
        hasRequestedAccessibilityPrompt = true

        let promptKey = kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String
        let options = [promptKey: true] as CFDictionary
        _ = AXIsProcessTrustedWithOptions(options)
    }

    private func waitForAccessibilityPermission() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }

            if AXIsProcessTrusted() {
                self.startMultitouchManager()
            } else {
                self.waitForAccessibilityPermission()
            }
        }
    }

    func synthesizeClick(at location: CGPoint, isRightClick: Bool) {
        if isRightClick {
            if let mouseDown = CGEvent(mouseEventSource: nil, mouseType: .rightMouseDown, mouseCursorPosition: location, mouseButton: .right) {
                mouseDown.post(tap: .cghidEventTap)
            }
            if let mouseUp = CGEvent(mouseEventSource: nil, mouseType: .rightMouseUp, mouseCursorPosition: location, mouseButton: .right) {
                mouseUp.post(tap: .cghidEventTap)
            }
        } else {
            if let mouseDown = CGEvent(mouseEventSource: nil, mouseType: .leftMouseDown, mouseCursorPosition: location, mouseButton: .left) {
                mouseDown.post(tap: .cghidEventTap)
            }
            if let mouseUp = CGEvent(mouseEventSource: nil, mouseType: .leftMouseUp, mouseCursorPosition: location, mouseButton: .left) {
                mouseUp.post(tap: .cghidEventTap)
            }
        }
    }
}