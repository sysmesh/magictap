import Cocoa
import ApplicationServices

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var multitouchManager: MultitouchManager?
    var isEnabled = true

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupMenuBar()

        // Check for accessibility permissions
        let trusted = AXIsProcessTrusted()
        if !trusted {
            showAccessibilityAlert()
            return
        }

        // Initialize multitouch manager
        multitouchManager = MultitouchManager()

        // Set up click synthesis callback
        multitouchManager?.onClickSynthesized = { [weak self] location, isRightClick in
            self?.synthesizeClick(at: location, isRightClick: isRightClick)
        }

        // Start monitoring
        multitouchManager?.start()
    }

    func showAccessibilityAlert() {
        let alert = NSAlert()
        alert.messageText = "Accessibility Permission Required"
        alert.informativeText = "Mouse Toucher needs accessibility permissions to simulate clicks.\n\nPlease grant permission in:\nSystem Settings > Privacy & Security > Accessibility"
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Open System Settings")
        alert.addButton(withTitle: "Quit")

        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!)
        }
        NSApplication.shared.terminate(nil)
    }

    func applicationWillTerminate(_ notification: Notification) {
        multitouchManager?.stop()
    }

    func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "computermouse.fill", accessibilityDescription: "Mouse Toucher")
        }

        let menu = NSMenu()

        let enabledItem = NSMenuItem(title: "Tap to Click: Enabled", action: #selector(toggleEnabled), keyEquivalent: "")
        enabledItem.state = isEnabled ? .on : .off
        menu.addItem(enabledItem)

        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "About Mouse Toucher", action: #selector(showAbout), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit Mouse Toucher", action: #selector(quit), keyEquivalent: "q"))

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

    @objc func showAbout() {
        let alert = NSAlert()
        alert.messageText = "Mouse Toucher"
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

    func synthesizeClick(at location: CGPoint, isRightClick: Bool) {
        if isRightClick {
            // Right click
            if let mouseDown = CGEvent(mouseEventSource: nil, mouseType: .rightMouseDown, mouseCursorPosition: location, mouseButton: .right) {
                mouseDown.post(tap: .cghidEventTap)
            }
            if let mouseUp = CGEvent(mouseEventSource: nil, mouseType: .rightMouseUp, mouseCursorPosition: location, mouseButton: .right) {
                mouseUp.post(tap: .cghidEventTap)
            }
        } else {
            // Left click
            if let mouseDown = CGEvent(mouseEventSource: nil, mouseType: .leftMouseDown, mouseCursorPosition: location, mouseButton: .left) {
                mouseDown.post(tap: .cghidEventTap)
            }
            if let mouseUp = CGEvent(mouseEventSource: nil, mouseType: .leftMouseUp, mouseCursorPosition: location, mouseButton: .left) {
                mouseUp.post(tap: .cghidEventTap)
            }
        }
    }
}
