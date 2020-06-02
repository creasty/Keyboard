import Cocoa

final class CursorKeyHandler: Handler {
    struct Const {
        static let superKey: KeyCode = .c
        static let speedKey: KeyCode = .s
        static let pauseInterval: UInt32 = 1000
    }
    
    enum Movement {
        case translate(x: CGFloat, y: CGFloat)
        case translatePropotionally(rx: CGFloat, ry: CGFloat)
        case moveTo(x: CGFloat, y: CGFloat)
        case movePropotionallyTo(rx: CGFloat, ry: CGFloat)
    }

    func activateSuperKeys() -> [KeyCode] {
        return [Const.superKey]
    }
    
    func handle(keyEvent: KeyEvent) -> HandlerAction? {
        return nil
    }

    func handleSuperKey(prefix: KeyCode, keys: Set<KeyCode>) -> Bool {
        guard prefix == Const.superKey else { return false }

        switch keys {
        case [.h]:
            moveCursor(.translate(x: -10, y: 0))
            return true
        case [.j]:
            moveCursor(.translate(x: 0, y: 10))
            return true
        case [.k]:
            moveCursor(.translate(x: 0, y: -10))
            return true
        case [.l]:
            moveCursor(.translate(x: 10, y: 0))
            return true
        
        case [.h, .j]:
            moveCursor(.translate(x: -10, y: 10))
            return true
        case [.j, .l]:
            moveCursor(.translate(x: 10, y: 10))
            return true
        case [.k, .l]:
            moveCursor(.translate(x: 10, y: -10))
            return true
        case [.h, .k]:
            moveCursor(.translate(x: -10, y: -10))
            return true

        case [Const.speedKey, .h]:
            moveCursor(.translatePropotionally(rx: -0.1, ry: 0))
            return true
        case [Const.speedKey, .j]:
            moveCursor(.translatePropotionally(rx: 0, ry: 0.1))
            return true
        case [Const.speedKey, .k]:
            moveCursor(.translatePropotionally(rx: 0, ry: -0.1))
            return true
        case [Const.speedKey, .l]:
            moveCursor(.translatePropotionally(rx: 0.1, ry: 0))
            return true

        case [Const.speedKey, .h, .j]:
            moveCursor(.translatePropotionally(rx: -0.1, ry: 0.1))
            return true
        case [Const.speedKey, .j, .l]:
            moveCursor(.translatePropotionally(rx: 0.1, ry: 0.1))
            return true
        case [Const.speedKey, .k, .l]:
            moveCursor(.translatePropotionally(rx: 0.1, ry: -0.1))
            return true
        case [Const.speedKey, .h, .k]:
            moveCursor(.translatePropotionally(rx: -0.1, ry: -0.1))
            return true

        case [.y]:
            moveCursor(.movePropotionallyTo(rx: 0.1, ry: 0.1))
            return true
        case [.u]:
            moveCursor(.movePropotionallyTo(rx: 0.1, ry: 0.9))
            return true
        case [.i]:
            moveCursor(.movePropotionallyTo(rx: 0.9, ry: 0.1))
            return true
        case [.o]:
            moveCursor(.movePropotionallyTo(rx: 0.9, ry: 0.9))
            return true
        case [.u, .i]:
            moveCursor(.movePropotionallyTo(rx: 0.5, ry: 0.5))
            return true

        case [.m]:
            mouseClick(.left)
            return true
        case [.comma]:
            mouseClick(.right)
            return true
        default:
            break
        }

        return false
    }

    func moveCursor(_ movement: Movement) {
        guard let screenRect = NSScreen.currentScreenRect else { return }
        guard let voidEvent = CGEvent(source: nil) else { return }

        var location = voidEvent.location

        switch movement {
        case let .translate(x, y):
            location.x += x
            location.y += y
        case let .translatePropotionally(rx, ry):
            location.x += screenRect.width * rx
            location.y += screenRect.height * ry
        case let .moveTo(x, y):
            location.x = x
            location.y = y
        case let .movePropotionallyTo(rx, ry):
            location.x = screenRect.minX + screenRect.width * rx
            location.y = screenRect.minY + screenRect.height * ry
        }

        // NOTE: -1 to workaround a problem of losing NSScreen.currentScreen.
        location.x = max(screenRect.minX, min(location.x, screenRect.maxX - 1))
        location.y = max(screenRect.minY, min(location.y, screenRect.maxY - 1))

        let event = CGEvent(
            mouseEventSource: nil,
            mouseType: .mouseMoved,
            mouseCursorPosition: location,
            mouseButton: .right
        )
        event?.post(tap: .cghidEventTap)
    }
    
    func mouseClick(_ button: CGMouseButton) {
        guard let voidEvent = CGEvent(source: nil) else { return }

        switch button {
        case .right:
            CGEvent(
                mouseEventSource: nil,
                mouseType: .rightMouseDown,
                mouseCursorPosition: voidEvent.location,
                mouseButton: .right
            )?.post(tap: .cghidEventTap)
            usleep(Const.pauseInterval)
            CGEvent(
                mouseEventSource: nil,
                mouseType: .rightMouseUp,
                mouseCursorPosition: voidEvent.location,
                mouseButton: .right
            )?.post(tap: .cghidEventTap)
        case .left:
            CGEvent(
                mouseEventSource: nil,
                mouseType: .leftMouseDown,
                mouseCursorPosition: voidEvent.location,
                mouseButton: .left
            )?.post(tap: .cghidEventTap)
            usleep(Const.pauseInterval)
            CGEvent(
                mouseEventSource: nil,
                mouseType: .leftMouseUp,
                mouseCursorPosition: voidEvent.location,
                mouseButton: .left
            )?.post(tap: .cghidEventTap)
        case .center:
            break
        }
    }
}
