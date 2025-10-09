import Cocoa

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate

// Run the app
_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
