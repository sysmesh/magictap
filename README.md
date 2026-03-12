MagicTap
A lightweight and simple tap-to-click for your Apple Magic Mouse!

Based on the fine work made by the original Mouse Toucher (https://github.com/meatpaste/mousetoucher), this forked and upgraded code now brings you a trackpad style of tap-to-click functionality with the Apple Magic Mouse.
Left click support, right click support, three fingers swipe up for Expose support and zoom in, out (by pinching) support added.

✨ Features
🖱️ Tap left side for left-click

🖱️ Tap right side for right-click

🖱️ Tap two fingers for middle-click

🖱️ Swipe three fingers up for Expose mode

🖱️ Pinch in/out for zooming in or out

⚡ Fast & responsive - no noticeable delay

Extremely small and lightweight - easy on your Mac's resources :-)

🎯 Easy toggle on/off from the menu bar

🔒 Privacy-focused - runs entirely on your Mac, no network access

📋 Requirements
macOS 11.0 (Big Sur) or later

Apple Magic Mouse (1st or 2nd generation)

Your Magic Mouse must be connected via Bluetooth

🚀 Installation
Option 1: Use Pre-Built Binary (Recommended)
A universal binary (works on both Apple Silicon and Intel Macs) is included in the build folder.

Bash
# Navigate to the repository
cd /path/to/magictap

# Copy to Applications
cp -r build/magictap.app /Applications/
Option 2: Build From Source
If you prefer to build it yourself:

Bash
cd /path/to/magictap
./build.sh   # Builds and ad-hoc codesigns the app so Accessibility permissions stick
cp -r build/MagicTap.app /Applications/
Grant Permissions
Open MagicTap from your Applications folder

You'll see a permission request - click "Open System Settings"

In Privacy & Security → Accessibility, enable MagicTap ✓

If the app is missing, click the + button and add it from /Applications/MagicTap.app

Return to MagicTap – it will begin working automatically once the toggle is on (no relaunch needed)

📖 How to Use
Basic Usage
Look for the mouse icon 🖱️ in your menu bar

Tap anywhere on your Magic Mouse surface to click

Tap left side = normal click

Tap right side = right-click

Physical clicking still works normally.

Menu Bar Controls
Click the icon to:

Enable/Disable tap-to-click

View About information

Quit the app

🔧 Auto-Start on Login (Optional)
To have MagicTap start automatically:

Open System Settings > General > Login Items

Click the + button

Select MagicTap from your Applications folder

Click Add

⚠️ Important Information
About Private Frameworks
MagicTap uses Apple's private MultitouchSupport framework.

✅ Safe to use - Widely used by similar utilities.

✅ Performance - Native responsiveness.

❌ Not on App Store - Private frameworks are restricted by Apple.

⚠️ Future updates - Major macOS updates could theoretically impact functionality.

Accessibility Permissions
MagicTap requires Accessibility permissions to detect touches and send click events. The app cannot function without them.

🐛 Troubleshooting
Taps aren't working
Go to System Settings → Privacy & Security → Accessibility

Ensure MagicTap is checked ✓

If issues persist after a rebuild, remove and re-add the app to the list.

Verify your Magic Mouse is connected via Bluetooth.

App won't launch
If you see an "App is damaged" error:

Right-click MagicTap → Open → Click Open again.

Or: Check System Settings → Privacy & Security and click Open Anyway.

Adjusting sensitivity
Open MultitouchManager.swift

Modify tapTimeThreshold or tapMovementThreshold.

Save and run ./build.sh.

🗑️ Uninstalling
Bash
# Remove the app
rm -rf /Applications/MagicTap.app

# Remove from Login Items via System Settings
# Revoke Accessibility permissions via System Settings
🙏 Credits
Based on the fine work made by the original MouseToucher code (https://github.com/meatpaste/mousetoucher).
Thanks to the reverse engineering community for documenting the MultitouchSupport framework.

Enjoy your new tap-to-click Magic Mouse! 🎉
