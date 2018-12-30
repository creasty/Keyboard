import Cocoa

// Needs to be globally accesible
var eventManager: EventManager?

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    private lazy var statusItem: NSStatusItem = {
        return NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    }()

    private let appComponent = AppComponent()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        guard isProcessTrusted() else {
            exit(1)
        }

        setupStatusItem()
        setupEventManager()
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
            menu.addItem(NSMenuItem(title: "Creasty's Keyboard", action: nil, keyEquivalent: ""))
            menu.addItem(NSMenuItem.separator())
            menu.addItem(NSMenuItem(title: "Quit", action: #selector(handleQuit), keyEquivalent: "q"))
            return menu
        }()
    }

    private func setupEventManager() {
        eventManager = appComponent.eventManager()
    }

    private func trapKeyEvents() {
        let eventMask = (1 << CGEventType.keyDown.rawValue) | (1 << CGEventType.keyUp.rawValue)

        guard let eventTap = CGEvent.tapCreate(
            tap: .cghidEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(eventMask),
            callback: { (_, _, event, _) -> Unmanaged<CGEvent>? in
                return eventManager!.handle(cgEvent: event)
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
        NSApplication.shared.terminate(nil)
    }
}
