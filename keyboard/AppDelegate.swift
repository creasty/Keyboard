import Cocoa

func openOrHideApplication(byBundleIdentifier id: String) {
    let workspace = NSWorkspace.shared()

    if let app = workspace.frontmostApplication, app.bundleIdentifier == id {
        app.hide()
    } else {
        workspace.launchApplication(
            withBundleIdentifier: id,
            options: [],
            additionalEventParamDescriptor: nil,
            launchIdentifier: nil
        )
    }
}

func handleKeyEvent(
    proxy: CGEventTapProxy,
    type: CGEventType,
    event: CGEvent,
    refcon: UnsafeMutableRawPointer?
) -> Unmanaged<CGEvent>? {
    guard let ev = NSEvent(cgEvent: event) else {
        return Unmanaged.passRetained(event)
    }

//    let flags = ev.modifierFlags

    if ev.type == .keyDown {
        if ev.keyCode == 12 /* && flags.contains(.command) */ {
            openOrHideApplication(byBundleIdentifier: "com.apple.finder")
            return nil
        }
    }

    return Unmanaged.passRetained(event)
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        trustThisApplication()
        trapKeyEvents()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
    }

    func trapKeyEvents() {
        let eventMask = (1 << CGEventType.keyDown.rawValue) | (1 << CGEventType.keyUp.rawValue)

        guard let eventTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(eventMask),
            callback: handleKeyEvent,
            userInfo: nil
        ) else {
            print("Failed to create event tap")
            exit(1)
        }

        let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: eventTap, enable: true)
        CFRunLoopRun()
    }

    private func trustThisApplication() {
        let opts = NSDictionary(
            object: kCFBooleanTrue,
            forKey: kAXTrustedCheckOptionPrompt.takeUnretainedValue() as NSString
        ) as CFDictionary

        guard AXIsProcessTrustedWithOptions(opts) else {
            exit(1)
        }
    }
}
