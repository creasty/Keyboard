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

    private var superKey: SuperKeyState = .inactive {
        didSet {
            if superKey != oldValue {
                NSLog("state = %@", String(describing: superKey))
            }
        }
    }

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

    func handle(cgEvent: CGEvent) -> Unmanaged<CGEvent>? {
        guard let event = NSEvent(cgEvent: cgEvent) else {
            return Unmanaged.passRetained(cgEvent)
        }

        let flags = event.modifierFlags

        // workspace.runningApplications
        // NSScreen.screens().first

        if let k = KeyCode(rawValue: event.keyCode), k == .a && flags.match() {
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
                    [true, false].forEach {
                        CGEvent(
                            keyboardEventSource: nil,
                            virtualKey: KeyCode.a.rawValue,
                            keyDown: $0
                            )?.post(tap: .cghidEventTap)
                    }
                    return nil

                default:
                    break
                }

            default:
                break
            }
        }

        if (superKey == .activated || superKey == .used) && flags.match() {
            superKey = .used

            if let k = KeyCode(rawValue: event.keyCode), k == .l && event.type == .keyDown {
                NSLog("--------------------- !!")
            }

            return nil
        }

        // Press Cmd-Q twice to "Quit Application"
        if event.type == .keyDown {
            if let k = KeyCode(rawValue: event.keyCode), k == .q && flags.match(command: true) {
                let t0 = lastTapTimes["Cmd-Q"]
                let t1 = DispatchTime.now()
                lastTapTimes["Cmd-Q"] = t1

                if let t0 = t0, Double(t1.uptimeNanoseconds) - Double(t0.uptimeNanoseconds) < 300 * 1e6 {
                    return Unmanaged.passRetained(cgEvent)
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

        return Unmanaged.passRetained(cgEvent)
    }
}
