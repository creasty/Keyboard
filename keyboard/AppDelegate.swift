import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    private lazy var statusItem: NSStatusItem = {
        return NSStatusBar.system().statusItem(withLength: NSSquareStatusItemLength)
    }()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        setupStatusItem()
        trustThisApplication()
        trapKeyEvents()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
    }

    private func setupStatusItem() {
        if let button = statusItem.button {
            button.title = "K"
            button.action = #selector(onOpen)
        }

        statusItem.menu = {
            let menu = NSMenu()

            menu.addItem(NSMenuItem(title: "Quit", action: #selector(onQuit), keyEquivalent: "q"))

            return menu
        }()
    }

    private func trapKeyEvents() {
        let eventMask = (1 << CGEventType.keyDown.rawValue) | (1 << CGEventType.keyUp.rawValue)

        guard let eventTap = CGEvent.tapCreate(
            tap: .cghidEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(eventMask),
            callback: { (_, _, event, _) -> Unmanaged<CGEvent>? in
                return EventManager.shared.handle(cgEvent: event)
            },
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

    func onQuit() {
        NSApplication.shared().terminate(nil)
    }

    func onOpen() {
    }
}
