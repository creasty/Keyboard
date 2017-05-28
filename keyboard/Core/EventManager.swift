import Cocoa

class EventManager {
    static let shared: EventManager = {
        return EventManager()
    }()

    private let workspace = NSWorkspace.shared()

    private var lastTapTimes = [String:DispatchTime]()

    private let superKeyCode: KeyCode = .s
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
        guard !cgEvent.flags.contains(.maskSecondaryFn) else {
            return Unmanaged.passRetained(cgEvent)
        }
        guard let event = NSEvent(cgEvent: cgEvent) else {
            return Unmanaged.passRetained(cgEvent)
        }
        guard let keyCode = KeyCode(rawValue: event.keyCode) else {
            return Unmanaged.passRetained(cgEvent)
        }

        let flags = event.modifierFlags

        // Set "super key" state
        if keyCode == superKeyCode && flags.match() {
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
                    press(key: .command)
                    return nil

                case .activated:
                    superKey = .disabled
                    press(key: superKeyCode, remap: true)
                    return nil

                default:
                    break
                }

            default:
                break
            }
        }

        // Window/Space navigations:
        //
        //     S+H: Move to left space
        //     S+L: Move to right space
        //     S+J: Switch to next application
        //     S+K: Switch to previous application
        //     S+N: Switch to next window
        //     S+B: Switch to previous window
        //
        if [.activated, .used].contains(superKey) && flags.match() {
            superKey = .used

            if event.type == .keyDown {
                switch keyCode {
                case .h:
                    press(key: .leftArrow, flags: [.maskControl])
                case .j:
                    press(key: .tab, flags: [.maskCommand])
                case .k:
                    press(key: .tab, flags: [.maskCommand, .maskShift])
                case .l:
                    press(key: .rightArrow, flags: [.maskControl])
                case .n:
                    press(key: .backtick, flags: [.maskCommand])
                case .b:
                    press(key: .backtick, flags: [.maskCommand, .maskShift])
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

        // Emacs:
        //
        //     Ctrl-C: Escape
        //     Ctrl-D: Forward delete
        //     Ctrl-H: Backspace
        //     Ctrl-J: Enter
        //     Ctrl-P: ↑
        //     Ctrl-N: ↓
        //     Ctrl-B: ←
        //     Ctrl-F: →
        //     Ctrl-A: Beginning of line (Shift allowed)
        //     Ctrl-E: End of line (Shift allowed)
        //
        if keyCode == .c && flags.match(control: true) {
            if event.type == .keyDown {
                press(key: .jisEisu)
            }
            press(key: .escape, actions: [event.type == .keyDown])
            return nil
        }
        if let bundleId = workspace.frontmostApplication?.bundleIdentifier, !emacsApplications.contains(bundleId) {
            if flags.match(control: true) {
                switch keyCode {
                case .d:
                    press(key: .forwardDelete, actions: [event.type == .keyDown])
                    return nil
                case .h:
                    press(key: .backspace, actions: [event.type == .keyDown])
                    return nil
                case .j:
                    press(key: .enter, actions: [event.type == .keyDown])
                    return nil
                case .p:
                    press(key: .upArrow, actions: [event.type == .keyDown])
                    return nil
                case .n:
                    press(key: .downArrow, actions: [event.type == .keyDown])
                    return nil
                case .b:
                    press(key: .leftArrow, actions: [event.type == .keyDown])
                    return nil
                case .f:
                    press(key: .rightArrow, actions: [event.type == .keyDown])
                    return nil
                case .a:
                    press(key: .leftArrow, flags: [.maskCommand], actions: [event.type == .keyDown])
                    return nil
                case .e:
                    press(key: .rightArrow, flags: [.maskCommand], actions: [event.type == .keyDown])
                    return nil
                default:
                    break
                }
            }
            if flags.match(shift: true, control: true) {
                switch keyCode {
                case .a:
                    press(key: .leftArrow, flags: [.maskCommand, .maskShift], actions: [event.type == .keyDown])
                    return nil
                case .e:
                    press(key: .rightArrow, flags: [.maskCommand, .maskShift], actions: [event.type == .keyDown])
                    return nil
                default:
                    break
                }
            }
        }

        // Leave InsMode with EISUU
        if event.type == .keyDown {
            if keyCode == .escape && flags.match() {
                press(key: .jisEisu)
                return Unmanaged.passRetained(cgEvent)
            }
        }

        // Application hotkeys:
        //
        //          Cmd-': Finder
        //     Ctrl-Cmd-': Evernote
        //
        if keyCode == .doubleQuote && event.type == .keyDown {
            if flags.match(command: true) {
                openOrHideApplication(byBundleIdentifier: "com.apple.finder")
                return nil
            }
            if flags.match(control: true, command: true) {
                openOrHideApplication(byBundleIdentifier: "com.evernote.Evernote")
                return nil
            }
        }

        return Unmanaged.passRetained(cgEvent)
    }

    private func press(key: KeyCode, flags: CGEventFlags = [], remap: Bool = false, actions: [Bool] = [true, false]) {
        actions.forEach {
            let e = CGEvent(
                keyboardEventSource: nil,
                virtualKey: key.rawValue,
                keyDown: $0
            )
            if remap {
                e?.flags = flags
            } else {
                e?.flags = flags.union(.maskSecondaryFn)
            }
            e?.post(tap: .cghidEventTap)
        }
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
