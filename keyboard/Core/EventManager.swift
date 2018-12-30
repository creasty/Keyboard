import Cocoa

final class EventManager {
    static let shared = EventManager()

    private let workspace = NSWorkspace.shared
    private let seq = KeySequence()
    private let superKey = SuperKey(key: .s)
    private let emitter = Emitter()

    enum Action {
        case prevent
        case passThrough
    }

    private init() {
    }

    func handle(cgEvent: CGEvent) -> Unmanaged<CGEvent>? {
        guard !cgEvent.flags.contains(Emitter.Const.noremapFlag) else {
            cgEvent.flags.remove(Emitter.Const.noremapFlag)
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

        let action = updateSuperKeyState(key: key, flags: flags, isKeyDown: isKeyDown, isARepeat: event.isARepeat)
            ?? handleSuperKey(key: key, flags: flags, isKeyDown: isKeyDown)
            ?? handleSafeQuit(key: key, flags: flags, isKeyDown: isKeyDown)
            ?? handleEmacsMode(key: key, flags: flags, isKeyDown: isKeyDown)
            ?? handleEscape(key: key, flags: flags, isKeyDown: isKeyDown)
            ?? handleWindowResizer(key: key, flags: flags, isKeyDown: isKeyDown)
            ?? .passThrough

        switch action {
        case .prevent:
            return nil
        case .passThrough:
            return Unmanaged.passRetained(cgEvent)
        }
    }

    private func updateSuperKeyState(key: KeyCode, flags: NSEvent.ModifierFlags, isKeyDown: Bool, isARepeat: Bool) -> Action? {
        guard flags.match() else {
            superKey.state = .inactive
            return nil
        }

        if key == superKey.prefixKey {
            guard !isARepeat else {
                return .prevent
            }
            guard !isKeyDown else {
                superKey.state = .activated
                return .prevent
            }

            switch superKey.state {
            case .activated:
                emitter.emit(key: superKey.prefixKey)
            case .used, .enabled:
                if let key = superKey.cancel() {
                    emitter.emit(key: superKey.prefixKey)
                    emitter.emit(key: key)
                } else {
                    emitter.emit(key: .command)
                }
            default: break
            }

            superKey.state = .inactive
            return .prevent
        }

        guard isKeyDown else {
            return nil
        }

        guard superKey.enable() else {
            superKey.state = .disabled

            emitter.emit(key: superKey.prefixKey)
            emitter.emit(key: key, action: (isKeyDown ? .down : .up))

            return .prevent
        }

        return nil
    }

    // Window/Space navigations:
    //
    //     S+H   Move to left space
    //     S+L   Move to right space
    //     S+J   Switch to next application
    //     S+K   Switch to previous application
    //     S+N   Switch to next window
    //     S+B   Switch to previous window
    //
    private func handleSuperKey(key: KeyCode, flags: NSEvent.ModifierFlags, isKeyDown: Bool) -> Action? {
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
                self?.emitter.emit(key: .leftArrow, flags: [.maskControl, .maskSecondaryFn])
            case .j:
                self?.emitter.emit(key: .tab, flags: [.maskCommand])
            case .k:
                self?.emitter.emit(key: .tab, flags: [.maskCommand, .maskShift])
            case .l:
                self?.emitter.emit(key: .rightArrow, flags: [.maskControl, .maskSecondaryFn])
            case .n:
                self?.emitter.emit(key: .backtick, flags: [.maskCommand])
            case .b:
                self?.emitter.emit(key: .backtick, flags: [.maskCommand, .maskShift])
            default:
                break
            }
        }

        return .prevent
    }

    // Press Cmd-Q twice to "Quit Application"
    private func handleSafeQuit(key: KeyCode, flags: NSEvent.ModifierFlags, isKeyDown: Bool) -> Action? {
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
    //     Ctrl-C    Escape
    //     Ctrl-D    Forward delete
    //     Ctrl-H    Backspace
    //     Ctrl-J    Enter
    //     Ctrl-P    ↑
    //     Ctrl-N    ↓
    //     Ctrl-B    ←
    //     Ctrl-F    →
    //     Ctrl-A    Beginning of line (Shift allowed)
    //     Ctrl-E    End of line (Shift allowed)
    //
    private func handleEmacsMode(key: KeyCode, flags: NSEvent.ModifierFlags, isKeyDown: Bool) -> Action? {
        guard let bundleId = workspace.frontmostApplication?.bundleIdentifier else {
            return nil
        }

        if !terminalApplications.contains(bundleId) {
            if key == .c && flags.match(control: true) {
                if isKeyDown {
                    emitter.emit(key: .jisEisu)
                }
                emitter.emit(key: .escape, action: (isKeyDown ? .down : .up))
                return .prevent
            }
        }

        if !emacsApplications.contains(bundleId) {
            var remap: (KeyCode, CGEventFlags)? = nil

            if flags.match(control: true) {
                switch key {
                case .d:
                    remap = (.forwardDelete, [])
                case .h:
                    remap = (.backspace, [])
                case .j:
                    remap = (.enter, [])
                default:
                    break
                }
            }
            if flags.match(shift: nil, control: true) {
                switch key {
                case .p:
                    remap = (.upArrow, [])
                case .n:
                    remap = (.downArrow, [])
                case .b:
                    remap = (.leftArrow, [])
                case .f:
                    remap = (.rightArrow, [])
                case .a:
                    remap = (.leftArrow, [.maskCommand])
                case .e:
                    remap = (.rightArrow, [.maskCommand])
                default:
                    break
                }
            }

            if let remap = remap {
                let remapFlags = flags.contains(.shift)
                    ? remap.1.union(.maskShift)
                    : remap.1

                emitter.emit(key: remap.0, flags: remapFlags, action: (isKeyDown ? .down : .up))
                return .prevent
            }
        }

        return nil
    }

    // Switch to EISUU with Escape key
    private func handleEscape(key: KeyCode, flags: NSEvent.ModifierFlags, isKeyDown: Bool) -> Action? {
        guard isKeyDown else {
            return nil
        }
        guard key == .escape else {
            return nil
        }
        guard flags.match() else {
            return nil
        }

        emitter.emit(key: .jisEisu)

        return .passThrough
    }

    // Window resizer:
    //
    //           Cmd-Alt-/        Full
    //           Cmd-Alt-Left     Left
    //           Cmd-Alt-Up       Top
    //           Cmd-Alt-Right    Right
    //           Cmd-Alt-Down     Bottom
    //     Shift-Cmd-Alt-Left     Top-left
    //     Shift-Cmd-Alt-Up       Top-right
    //     Shift-Cmd-Alt-Right    Bottom-right
    //     Shift-Cmd-Alt-Down     Bottom-left
    //
    private func handleWindowResizer(key: KeyCode, flags: NSEvent.ModifierFlags, isKeyDown: Bool) -> Action? {
        guard isKeyDown else {
            return nil
        }
        guard flags.match(shift: nil, option: true, command: true) else {
            return nil
        }

        var windowSize: WindowSize?

        if flags.contains(.shift) {
            switch key {
            case .leftArrow:  windowSize = .topLeft
            case .upArrow:    windowSize = .topRight
            case .rightArrow: windowSize = .bottomRight
            case .downArrow:  windowSize = .bottomLeft
            default: break
            }
        } else {
            switch key {
            case .slash:      windowSize = .full
            case .leftArrow:  windowSize = .left
            case .upArrow:    windowSize = .top
            case .rightArrow: windowSize = .right
            case .downArrow:  windowSize = .bottom
            default: break
            }
        }

        if let windowSize = windowSize {
            do {
                try resizeWindow(windowSize: windowSize)
            } catch {
                print(error)
            }

            return .prevent
        }

        return nil
    }

    private func resizeWindow(windowSize: WindowSize) throws {
        guard let app = workspace.frontmostApplication?.axUIElement() else { return }
        guard let window = try app.getAttribute(AXAttributes.focusedWindow) else { return }
        guard let frame = try window.getAttribute(AXAttributes.frame) else { return }

        guard let screen = (NSScreen.screens
            .map { screen in (screen, screen.frame.intersection(frame)) }
            .filter { _, intersect in !intersect.isNull }
            .map { screen, intersect in (screen, intersect.size.width * intersect.size.height) }
            .max { lhs, rhs in lhs.1 < rhs.1 }?
            .0
        ) else {
            return
        }

        let newFrame = windowSize.rect(screenFrame: screen.frame)

        try window.setAttribute(AXAttributes.position, value: newFrame.origin)
        try window.setAttribute(AXAttributes.size, value: newFrame.size)
    }

    private func showOrHideApplication(byBundleIdentifier id: String) {
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
