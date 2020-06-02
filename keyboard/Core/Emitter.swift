import Cocoa

enum EmitterKeyAction {
    case down
    case up
    case both

    fileprivate var keyDowns: [(isDown: Bool, pause: Bool)] {
        switch self {
        case .down:
            return [(isDown: true, pause: false)]
        case .up:
            return [(isDown: false, pause: false)]
        case .both:
            return [(isDown: true, pause: true), (isDown: false, pause: false)]
        }
    }
}

enum EmitterMouseButton {
    case left
    case right

    fileprivate var eventParams: (CGEventType, CGEventType, CGMouseButton) {
        switch self {
        case .left:
            return (.leftMouseDown, .leftMouseUp, .left)
        case .right:
            return (.rightMouseDown, .rightMouseUp, .right)
        }
    }
}

protocol EmitterType {
    func setProxy(_ proxy: CGEventTapProxy?)

    func emit(keyCode: KeyCode, flags: CGEventFlags, action: EmitterKeyAction)
    func emit(mouseMoveTo location: CGPoint)
    func emit(mouseClick button: EmitterMouseButton)
}

class Emitter: EmitterType {
    struct Const {
        // NOTE: it's not possible to post consecutive events
        static let pauseInterval: UInt32 = 1000
    }

    private var proxy: CGEventTapProxy?

    func setProxy(_ proxy: CGEventTapProxy?) {
        self.proxy = proxy
    }

    func emit(keyCode: KeyCode, flags: CGEventFlags, action: EmitterKeyAction) {
        action.keyDowns.forEach {
            if $0.pause {
                usleep(Const.pauseInterval)
            }

            let e = CGEvent(
                keyboardEventSource: nil,
                virtualKey: keyCode.rawValue,
                keyDown: $0.isDown
            )
            e?.flags = flags
            e?.tapPostEvent(proxy)
        }
    }

    func emit(mouseMoveTo location: CGPoint) {
        CGEvent(
            mouseEventSource: nil,
            mouseType: .mouseMoved,
            mouseCursorPosition: location,
            mouseButton: .right
        )?.post(tap: .cghidEventTap)
    }

    func emit(mouseClick button: EmitterMouseButton) {
        guard let voidEvent = CGEvent(source: nil) else { return }

        let (downEventType, upEventType, cgMouseButton) = button.eventParams

        CGEvent(
            mouseEventSource: nil,
            mouseType: downEventType,
            mouseCursorPosition: voidEvent.location,
            mouseButton: cgMouseButton
        )?.post(tap: .cghidEventTap)

        usleep(Const.pauseInterval)

        CGEvent(
            mouseEventSource: nil,
            mouseType: upEventType,
            mouseCursorPosition: voidEvent.location,
            mouseButton: cgMouseButton
        )?.post(tap: .cghidEventTap)
    }
}

