import Cocoa

extension NSEventModifierFlags {
    func match(
        shift: Bool = false,
        control: Bool = false,
        option: Bool = false,
        command: Bool = false
    ) -> Bool {
        return contains(.shift) == shift &&
            contains(.control) == control &&
            contains(.option) == option &&
            contains(.command) == command
    }
}

class EventManager {
    static let shared: EventManager = {
        return EventManager()
    }()

    private let workspace = NSWorkspace.shared()

    private var lastTapTimes = [String:DispatchTime]()
    private var isHijacked: Bool = true

    private var superKey: SuperKeyState = .inactive {
        didSet {
            if superKey != oldValue {
                NSLog("state = %@", String(describing: superKey))
            }
        }
    }

    private init() {
    }

    func handle(cgEvent: CGEvent) -> Unmanaged<CGEvent>? {
        guard isHijacked else {
            return Unmanaged.passRetained(cgEvent)
        }
        guard let event = NSEvent(cgEvent: cgEvent) else {
            return Unmanaged.passRetained(cgEvent)
        }
        guard let keyCode = KeyCode(rawValue: event.keyCode) else {
            return Unmanaged.passRetained(cgEvent)
        }

        let flags = event.modifierFlags

        // workspace.runningApplications
        // NSScreen.screens().first

        // Set "super key" state
        if keyCode == .a && flags.match() {
            switch event.type {
            case .keyDown:
                switch superKey {
                case .disabled:
                    superKey = .inactive
                    return Unmanaged.passRetained(cgEvent)

                default:
                    superKey = .activated
                    return nil
                }

            case .keyUp:
                switch superKey {
                case .used:
                    superKey = .inactive
                    return nil

                case .activated:
                    superKey = .disabled
                    press(key: .a)
                    return nil

                default:
                    break
                }

            default:
                break
            }
        }

        // Window/Space navigation
        if (superKey == .activated || superKey == .used) && flags.match() {
            superKey = .used

            /**
             * S+H: Move to left space
             * S+L: Move to right space
             * S+J: Switch to next application
             * S+K: Switch to previous application
             * S+N: Switch to next window
             * S+B: Switch to previous window
             */
            if event.type == .keyDown {
                switch keyCode {
                case .h:
                    press(key: .leftArrow, flags: [.maskControl], remap: false)
                case .j:
                    press(key: .tab, flags: [.maskCommand], remap: false)
                case .k:
                    press(key: .tab, flags: [.maskCommand, .maskShift], remap: false)
                case .l:
                    press(key: .rightArrow, flags: [.maskControl], remap: false)
                case .n:
                    press(key: .backtick, flags: [.maskCommand], remap: false)
                case .b:
                    press(key: .backtick, flags: [.maskCommand, .maskShift], remap: false)
                default:
                    break
                }
            }

            return nil
        }

        // Press Cmd-Q twice to "Quit Application"
        if event.type == .keyDown {
            if keyCode == .q && flags.match(command: true) {
                let t0 = lastTapTimes["Cmd-Q"]
                let t1 = DispatchTime.now()
                lastTapTimes["Cmd-Q"] = t1

                if let t0 = t0, Double(t1.uptimeNanoseconds) - Double(t0.uptimeNanoseconds) < 300 * 1e6 {
                    return Unmanaged.passRetained(cgEvent)
                }

                return nil
            }
        }

        // Emacs
        if keyCode == .c && flags.match(control: true) {
            if event.type == .keyDown {
                press(key: .escape)
            }
            return nil
        }

        // Leave InsMode with EISUU
        if event.type == .keyDown {
            if keyCode == .escape && flags.match() {
                press(key: .jisEisu, remap: false)
                return Unmanaged.passRetained(cgEvent)
            }
        }

//        if ev.type == .keyDown {
//            if ev.keyCode == KeyCode["A"] && flags == [] {
//                openOrHideApplication(byBundleIdentifier: "com.apple.finder")
//                return nil
//            }
//        }

        return Unmanaged.passRetained(cgEvent)
    }

    private func press(key: KeyCode, flags: CGEventFlags = [], remap: Bool = true) {
        isHijacked = remap

        [true, false].forEach {
            let e = CGEvent(
                keyboardEventSource: nil,
                virtualKey: key.rawValue,
                keyDown: $0
            )
            e?.flags = flags
            e?.post(tap: .cghidEventTap)
        }

        isHijacked = true
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
}
