import Cocoa

final class EventManager {
    static let shared: EventManager = {
        return EventManager()
    }()

    private let workspace = NSWorkspace.shared()
    private let seq = KeySequence()
    private let superKey = SuperKey(key: .s)
    private let noremapFlag: CGEventFlags = .maskHelp

    enum Action {
        case prevent
        case passThrough
    }
    enum KeyPressAction {
        case down
        case up
        case both

        func keyDowns() -> [Bool] {
            switch self {
            case .down:
                return [true]
            case .up:
                return [false]
            case .both:
                return [true, false]
            }
        }
    }

    private init() {
    }

    func handle(cgEvent: CGEvent) -> Unmanaged<CGEvent>? {
        guard !cgEvent.flags.contains(noremapFlag) else {
            cgEvent.flags.remove(noremapFlag)
            return Unmanaged.passRetained(cgEvent)
        }
        guard let event = NSEvent(cgEvent: cgEvent) else {
            return Unmanaged.passRetained(cgEvent)
        }
        guard let key = KeyCode(rawValue: event.keyCode) else {
            return Unmanaged.passRetained(cgEvent)
        }

        let flags = event.modifierFlags
        let isKeyDown = (event.type == .keyDown)

//        NSLog("\(String(describing: key)) \(isKeyDown ? "down" : "up")")

        let action = updateSuperKeyState(key: key, flags: flags, isKeyDown: isKeyDown)
            ?? handleSuperKey(key: key, flags: flags, isKeyDown: isKeyDown)
            ?? handleSafeQuit(key: key, flags: flags, isKeyDown: isKeyDown)
            ?? handleEmacsMode(key: key, flags: flags, isKeyDown: isKeyDown)
            ?? handleEscape(key: key, flags: flags, isKeyDown: isKeyDown)
            ?? handleAppHotkey(key: key, flags: flags, isKeyDown: isKeyDown)
            ?? .passThrough

        switch action {
        case .prevent:
            return nil
        case .passThrough:
            return Unmanaged.passRetained(cgEvent)
        }
    }

    private func updateSuperKeyState(key: KeyCode, flags: NSEventModifierFlags, isKeyDown: Bool) -> Action? {
        guard flags.match() else {
            superKey.state = .inactive
            return nil
        }

        if key == superKey.hookedKey {
            if isKeyDown {
                superKey.state = .activated
                return .prevent
            } else {
                switch superKey.state {
                case .activated:
                    press(key: superKey.hookedKey)
                case .used, .enabled:
                    if let key = superKey.cancel() {
                        press(key: superKey.hookedKey)
                        press(key: key)
                    } else {
                        press(key: .command)
                    }
                default: break
                }
                superKey.state = .inactive
                return .prevent
            }
        }

        guard superKey.enable() else {
            superKey.state = .disabled

            press(key: superKey.hookedKey)
            press(key: key, action: (isKeyDown ? .down : .up))

            return .prevent
        }

        return nil
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
    private func handleSuperKey(key: KeyCode, flags: NSEventModifierFlags, isKeyDown: Bool) -> Action? {
        guard superKey.isEnabled else {
            return nil
        }
        guard flags.match() else {
            return nil
        }

        superKey.perform(key: key) { [weak self] in
            guard isKeyDown else {
                return
            }

            switch key {
            case .h:
                self?.press(key: .leftArrow, flags: [.maskControl, .maskSecondaryFn])
            case .j:
                self?.press(key: .tab, flags: [.maskCommand])
            case .k:
                self?.press(key: .tab, flags: [.maskCommand, .maskShift])
            case .l:
                self?.press(key: .rightArrow, flags: [.maskControl, .maskSecondaryFn])
            case .n:
                self?.press(key: .backtick, flags: [.maskCommand])
            case .b:
                self?.press(key: .backtick, flags: [.maskCommand, .maskShift])
            default:
                break
            }
        }

        return .prevent
    }

    // Press Cmd-Q twice to "Quit Application"
    private func handleSafeQuit(key: KeyCode, flags: NSEventModifierFlags, isKeyDown: Bool) -> Action? {
        guard isKeyDown else {
            return nil
        }
        guard key == .q else {
            return nil
        }
        guard flags.match(command: true) else {
            return nil
        }

        if seq.record(forKey: #function) == 2 {
            seq.reset(forKey: #function)
            return .passThrough
        }

        return .prevent
    }

    // Emacs mode:
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
    private func handleEmacsMode(key: KeyCode, flags: NSEventModifierFlags, isKeyDown: Bool) -> Action? {
        if key == .c && flags.match(control: true) {
            if isKeyDown {
                press(key: .jisEisu)
            }
            press(key: .escape, action: (isKeyDown ? .down : .up))
            return .prevent
        }

        guard let bundleId = workspace.frontmostApplication?.bundleIdentifier, !emacsApplications.contains(bundleId) else {
            return nil
        }

        if flags.match(control: true) {
            switch key {
            case .d:
                press(key: .forwardDelete, action: (isKeyDown ? .down : .up))
                return .prevent
            case .h:
                press(key: .backspace, action: (isKeyDown ? .down : .up))
                return .prevent
            case .j:
                press(key: .enter, action: (isKeyDown ? .down : .up))
                return .prevent
            case .p:
                press(key: .upArrow, action: (isKeyDown ? .down : .up))
                return .prevent
            case .n:
                press(key: .downArrow, action: (isKeyDown ? .down : .up))
                return .prevent
            case .b:
                press(key: .leftArrow, action: (isKeyDown ? .down : .up))
                return .prevent
            case .f:
                press(key: .rightArrow, action: (isKeyDown ? .down : .up))
                return .prevent
            case .a:
                press(key: .leftArrow, flags: [.maskCommand], action: (isKeyDown ? .down : .up))
                return .prevent
            case .e:
                press(key: .rightArrow, flags: [.maskCommand], action: (isKeyDown ? .down : .up))
                return .prevent
            default:
                break
            }
        }
        if flags.match(shift: true, control: true) {
            switch key {
            case .a:
                press(key: .leftArrow, flags: [.maskCommand, .maskShift], action: (isKeyDown ? .down : .up))
                return .prevent
            case .e:
                press(key: .rightArrow, flags: [.maskCommand, .maskShift], action: (isKeyDown ? .down : .up))
                return .prevent
            default:
                break
            }
        }

        return nil
    }

    // Switch to EISUU with Escape key
    private func handleEscape(key: KeyCode, flags: NSEventModifierFlags, isKeyDown: Bool) -> Action? {
        guard isKeyDown else {
            return nil
        }
        guard key == .escape else {
            return nil
        }
        guard flags.match() else {
            return nil
        }

        press(key: .jisEisu)

        return .passThrough
    }

    // Application hotkeys:
    //
    //          Cmd-': Finder
    //     Ctrl-Cmd-': Evernote
    //
    private func handleAppHotkey(key: KeyCode, flags: NSEventModifierFlags, isKeyDown: Bool) -> Action? {
        guard isKeyDown else {
            return nil
        }
        guard key == .doubleQuote else {
            return nil
        }

        if flags.match(command: true) {
            openOrHideApplication(byBundleIdentifier: "com.apple.finder")
            return .prevent
        }
        if flags.match(control: true, command: true) {
            openOrHideApplication(byBundleIdentifier: "com.evernote.Evernote")
            return .prevent
        }

        return nil
    }

    private func press(
        key: KeyCode,
        flags: CGEventFlags = [],
        action: KeyPressAction = .both
    ) {
        action.keyDowns().forEach {
            if !$0 && action == .both {
                usleep(1000)
            }

            let e = CGEvent(
                keyboardEventSource: nil,
                virtualKey: key.rawValue,
                keyDown: $0
            )
            e?.flags = flags.union(noremapFlag)
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
