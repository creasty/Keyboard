import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    private lazy var statusItem: NSStatusItem = {
        return NSStatusBar.system().statusItem(withLength: NSSquareStatusItemLength)
    }()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        guard isProcessTrusted() else {
            exit(1)
        }

        setupStatusItem()
        trapKeyEvents()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
    }

    private func setupStatusItem() {
        if let button = statusItem.button {
            button.title = "K"
        }

        statusItem.menu = {
            let menu = NSMenu()
            menu.addItem(NSMenuItem(title: "Quit", action: #selector(handleQuit), keyEquivalent: "q"))
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
            fatalError("Failed to create event tap")
        }

        let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: eventTap, enable: true)
        CFRunLoopRun()
    }

    private func isProcessTrusted() -> Bool {
        let promptKey = kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String
        let opts = [promptKey: true] as CFDictionary

        return AXIsProcessTrustedWithOptions(opts)
    }

    @objc
    private func handleQuit() {
        NSApplication.shared().terminate(nil)
    }
}
