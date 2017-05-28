import Cocoa

final class EventManager {
    static let shared: EventManager = {
        return EventManager()
    }()

    private let workspace = NSWorkspace.shared()
    private let seq = KeySequence()
    private let superKey = SuperKey(key: .s)

    enum Action {
        case prevent
        case passThrough
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
        guard let key = KeyCode(rawValue: event.keyCode) else {
            return Unmanaged.passRetained(cgEvent)
        }

        let flags = event.modifierFlags
        let isKeyDown = (event.type == .keyDown)

        let action = updateSuperKeyState(key: key, flags: flags, isKeyDown: isKeyDown)
            ?? handleSuperKey(key: key, flags: flags, isKeyDown: isKeyDown)
            ?? handleSafeQuit(key: key, flags: flags, isKeyDown: isKeyDown)
            ?? handleEmacsMode(key: key, flags: flags, isKeyDown: isKeyDown)
            ?? handleEscape(key: key, flags: flags, isKeyDown: isKeyDown)
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
                case .enabled:
                    press(key: .command)
                default: break
                }
                superKey.state = .inactive
                return .prevent
            }
        }

        if superKey.state == .activated {
            guard superKey.canBeEnabled() else {
                superKey.state = .disabled

                if isKeyDown {
                    press(key: superKey.hookedKey)
                }
                press(key: key, actions: [isKeyDown])
                return .prevent
            }

            superKey.state = .enabled
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
        guard superKey.state == .enabled else {
            return nil
        }
        guard isKeyDown else {
            return nil
        }
        guard flags.match() else {
            return nil
        }

        switch key {
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
            press(key: .escape, actions: [isKeyDown])
            return .prevent
        }

        guard let bundleId = workspace.frontmostApplication?.bundleIdentifier, !emacsApplications.contains(bundleId) else {
            return nil
        }

        if flags.match(control: true) {
            switch key {
            case .d:
                press(key: .forwardDelete, actions: [isKeyDown])
                return .prevent
            case .h:
                press(key: .backspace, actions: [isKeyDown])
                return .prevent
            case .j:
                press(key: .enter, actions: [isKeyDown])
                return .prevent
            case .p:
                press(key: .upArrow, actions: [isKeyDown])
                return .prevent
            case .n:
                press(key: .downArrow, actions: [isKeyDown])
                return .prevent
            case .b:
                press(key: .leftArrow, actions: [isKeyDown])
                return .prevent
            case .f:
                press(key: .rightArrow, actions: [isKeyDown])
                return .prevent
            case .a:
                press(key: .leftArrow, flags: [.maskCommand], actions: [isKeyDown])
                return .prevent
            case .e:
                press(key: .rightArrow, flags: [.maskCommand], actions: [isKeyDown])
                return .prevent
            default:
                break
            }
        }
        if flags.match(shift: true, control: true) {
            switch key {
            case .a:
                press(key: .leftArrow, flags: [.maskCommand, .maskShift], actions: [isKeyDown])
                return .prevent
            case .e:
                press(key: .rightArrow, flags: [.maskCommand, .maskShift], actions: [isKeyDown])
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
