import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let opts = NSDictionary(
            object: kCFBooleanTrue,
            forKey: kAXTrustedCheckOptionPrompt.takeUnretainedValue() as NSString
        ) as CFDictionary

        guard AXIsProcessTrustedWithOptions(opts) else {
            return
        }

        NSEvent.addGlobalMonitorForEvents(matching: [.keyDown, .keyUp]) { (event) in
            let flags = event.modifierFlags

            NSLog("%@", event)

            if event.type == .keyDown {
                if event.keyCode == 53 && flags.contains(.command) {
                    NSWorkspace.shared().launchApplication("Finder")
//                    NSWorkspace.shared().launchApplication(
//                        withBundleIdentifier: "com.apple.Finder",
//                        options: [],
//                        additionalEventParamDescriptor: nil,
//                        launchIdentifier: nil
//                    )
                }
            }
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
    }


}

