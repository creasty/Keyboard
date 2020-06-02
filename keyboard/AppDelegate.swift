import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    private lazy var statusItem: NSStatusItem = {
        return NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    }()

    private lazy var appComponent: AppComponent = {
        return AppComponent(showHighlightCallback: { [weak self] in
            self?.showHighlight()
        })
    }()

    private var window: NSWindow?
    private var highlighterWork: DispatchWorkItem?
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        guard isProcessTrusted() else {
            exit(1)
        }

        setupWindow()
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
        _eventManager = appComponent.eventManager()
    }

    private func setupWindow() {
        let window = NSWindow(contentRect: .zero, styleMask: .borderless, backing: .buffered, defer: true)
        window.isOpaque = false
        window.makeKeyAndOrderFront(nil)
        window.backgroundColor = .clear
        window.level = .floating
        self.window = window
    }

    private func trapKeyEvents() {
        let eventMask = (1 << CGEventType.keyDown.rawValue) | (1 << CGEventType.keyUp.rawValue)

        guard let eventTap = CGEvent.tapCreate(
            tap: .cghidEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(eventMask),
            callback: appComponent.eventTapCallback,
            userInfo: nil
        ) else {
            fatalError("Failed to create event tap")
        }
        _eventTap = eventTap

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

    private func showHighlight() {
        guard let screen = NSScreen.currentScreen else { return }
        guard let window = window else { return }

        let highlighterView = HighlighterView(frame: screen.frame)
        highlighterView.location = {
            var mouseLocation = NSEvent.mouseLocation
            mouseLocation.x -= screen.frame.origin.x
            mouseLocation.y -= screen.frame.origin.y
            return mouseLocation
        }()

        highlighterWork?.cancel()
        let work = DispatchWorkItem() { self.hideHighlight() }
        highlighterWork = work

        window.contentView = highlighterView
        window.setFrame(screen.frame, display: true)

        let dispatchTime = DispatchTime.now() + DispatchTimeInterval.seconds(1)
        DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: work)
    }

    private func hideHighlight() {
        window?.contentView = nil
        window?.setFrame(.zero, display: false)
    }
}
