import Cocoa

public let KeyCode: [String:UInt16] = [
    "A":              0x00,
    "S":              0x01,
    "D":              0x02,
    "F":              0x03,
    "H":              0x04,
    "G":              0x05,
    "Z":              0x06,
    "X":              0x07,
    "C":              0x08,
    "V":              0x09,
    "B":              0x0b,
    "Q":              0x0c,
    "W":              0x0d,
    "E":              0x0e,
    "R":              0x0f,
    "Y":              0x10,
    "T":              0x11,
    "1":              0x12,
    "2":              0x13,
    "3":              0x14,
    "4":              0x15,
    "5":              0x17,
    "6":              0x16,
    "=":              0x18,
    "9":              0x19,
    "7":              0x1a,
    "-":              0x1b,
    "8":              0x1c,
    "0":              0x1d,
    "]":              0x1e,
    "O":              0x1f,
    "U":              0x20,
    "[":              0x21,
    "I":              0x22,
    "P":              0x23,
    "L":              0x25,
    "J":              0x26,
    "\"":             0x27,
    "K":              0x28,
    ";":              0x29,
    "\\":             0x2a,
    ",":              0x2b,
    "/":              0x2c,
    "N":              0x2d,
    "M":              0x2e,
    ".":              0x2f,
    "Grave":          0x32,
    "KeypadDecimal":  0x41,
    "KeypadMultiply": 0x43,
    "KeypadPlus":     0x45,
    "KeypadClear":    0x47,
    "KeypadDivide":   0x4b,
    "KeypadEnter":    0x4c,
    "KeypadMinus":    0x4e,
    "KeypadEquals":   0x51,
    "Keypad0":        0x52,
    "Keypad1":        0x53,
    "Keypad2":        0x54,
    "Keypad3":        0x55,
    "Keypad4":        0x56,
    "Keypad5":        0x57,
    "Keypad6":        0x58,
    "Keypad7":        0x59,
    "Keypad8":        0x5b,
    "Keypad9":        0x5c,

    // keycodes for keys that are independent of keyboard layout
    "Return":        0x24,
    "Tab":           0x30,
    "Space":         0x31,
    "Delete":        0x33,
    "Escape":        0x35,
    "Command":       0x37,
    "Shift":         0x38,
    "CapsLock":      0x39,
    "Option":        0x3a,
    "Control":       0x3b,
    "RightShift":    0x3c,
    "RightOption":   0x3d,
    "RightControl":  0x3e,
    "Function":      0x3f,
    "F17":           0x40,
    "VolumeUp":      0x48,
    "VolumeDown":    0x49,
    "Mute":          0x4a,
    "F18":           0x4f,
    "F19":           0x50,
    "F20":           0x5a,
    "F5":            0x60,
    "F6":            0x61,
    "F7":            0x62,
    "F3":            0x63,
    "F8":            0x64,
    "F9":            0x65,
    "F11":           0x67,
    "F13":           0x69,
    "F16":           0x6a,
    "F14":           0x6b,
    "F10":           0x6d,
    "F12":           0x6f,
    "F15":           0x71,
    "Help":          0x72,
    "Home":          0x73,
    "PageUp":        0x74,
    "ForwardDelete": 0x75,
    "F4":            0x76,
    "End":           0x77,
    "F2":            0x78,
    "PageDown":      0x79,
    "F1":            0x7a,
    "LeftArrow":     0x7b,
    "RightArrow":    0x7c,
    "DownArrow":     0x7d,
    "UpArrow":       0x7e,

    // The following were discovered using the Key Codes app
    "Backspace": 0x33,
    "Enter":     0x24,
    "<":         0x2b,
    ">":         0x2f,
    "{":         0x21,
    "}":         0x1e,
    ")":         0x1d,
    "(":         0x19,
    "!":         0x12,
    "|":         0x2a,
    ":":         0x29,
    "`":         0x32,
    "'":         0x27,
    "&":         0x1a,
    "%":         0x17,
    "?":         0x2c,
    "*":         0x1c,
    "~":         0x32,
    "@":         0x13,
    "$":         0x15,
    "^":         0x16,
    "+":         0x18,
    "#":         0x14,

    // ISO keyboards only
    "Section": 0x0a,

    // JIS keyboards only
    "Yen":         0x5d,
    "_":           0x5e,
    "KeypadComma": 0x5f,
    "Eisu":        0x66,
    "Kana":        0x68,
]

class EventManager {
    static let shared: EventManager = {
        return EventManager()
    }()

    private let workspace = NSWorkspace.shared()

    private var lastTapTimes = [String:DispatchTime]()

    private init() {
    }

    private func openOrHideApplication(byBundleIdentifier id: String) {
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

    func handle(event: CGEvent) -> Unmanaged<CGEvent>? {
        guard let ev = NSEvent(cgEvent: event) else {
            return Unmanaged.passRetained(event)
        }

        let flags = ev.modifierFlags

        // workspace.runningApplications
        // NSScreen.screens().first

        // Press Cmd-Q twice to "Quit Application"
        if ev.type == .keyDown {
            if ev.keyCode == KeyCode["Q"] && flags.contains(.command) && !flags.contains(.shift) && !flags.contains(.control) && !flags.contains(.option) {
                let t0 = lastTapTimes["Cmd-Q"]
                let t1 = DispatchTime.now()
                lastTapTimes["Cmd-Q"] = t1

                if let t0 = t0, Double(t1.uptimeNanoseconds) - Double(t0.uptimeNanoseconds) < 300 * 1e6 {
                    return Unmanaged.passRetained(event)
                }

                return nil
            }
        }

//        if ev.type == .keyDown {
//            if ev.keyCode == KeyCode["A"] && flags == [] {
//                openOrHideApplication(byBundleIdentifier: "com.apple.finder")
//                return nil
//            }
//        }

        return Unmanaged.passRetained(event)
    }
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

    private func trapKeyEvents() {
        let eventMask = (1 << CGEventType.keyDown.rawValue) | (1 << CGEventType.keyUp.rawValue)

        guard let eventTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(eventMask),
            callback: { (_, _, event, _) -> Unmanaged<CGEvent>? in
                return EventManager.shared.handle(event: event)
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
}
