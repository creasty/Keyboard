import Cocoa

final class CursorKeyHandler: Handler {
    struct Const {
        static let superKey: KeyCode = .c
    }
    
    enum Movement {
        case translate(x: CGFloat, y: CGFloat)
        case translatePropotionally(rx: CGFloat, ry: CGFloat)
        case moveTo(x: CGFloat, y: CGFloat)
        case movePropotionallyTo(rx: CGFloat, ry: CGFloat)
    }

    private let workspace: NSWorkspace

    init(workspace: NSWorkspace) {
        self.workspace = workspace
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
        case [.d, .h]:
            moveCursor(.translatePropotionally(rx: -0.1, ry: 0))
            return true
        case [.d, .j]:
            moveCursor(.translatePropotionally(rx: 0, ry: 0.1))
            return true
        case [.d, .k]:
            moveCursor(.translatePropotionally(rx: 0, ry: -0.1))
            return true
        case [.d, .l]:
            moveCursor(.translatePropotionally(rx: 0.1, ry: 0))
            return true
        default:
            break
        }

        return false
    }

    func moveCursor(_ movement: Movement) {
        let mouseLocation = NSEvent.mouseLocation

        guard let mainScreen = NSScreen.main else { return }
        guard let currentScreen = NSScreen.screens.first(where: { NSMouseInRect(mouseLocation, $0.frame, false) }) else { return }

        var screenRect = currentScreen.frame
        screenRect.origin.y = (mainScreen.frame.origin.y + mainScreen.frame.size.height) - (currentScreen.frame.origin.y + currentScreen.frame.size.height)

        guard let voidEvent = CGEvent(source: nil) else { return }
        var location = voidEvent.location
//        print("CGEvent#location =", location)
//        print("screenRect =", screenRect)

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

        let event = CGEvent(
            mouseEventSource: nil,
            mouseType: .mouseMoved,
            mouseCursorPosition: location,
            mouseButton: .left
        )
        event?.post(tap: .cghidEventTap)
    }
}
