import Cocoa

final class CursorKeyHandler: Handler {
    private let workspace: NSWorkspace

    init(workspace: NSWorkspace) {
        self.workspace = workspace
    }

    func activateSuperKeys() -> [KeyCode] {
        return [.d]
    }
    
    func handle(keyEvent: KeyEvent) -> HandlerAction? {
        return nil
    }

    func handleSuperKey(prefix: KeyCode, keys: Set<KeyCode>) -> Bool {
        guard prefix == .d else { return false }

        switch keys {
        case [.j]:
            moveCursor()
        default:
            break
        }

        return false
    }

    func moveCursor() {
        guard let screen = NSScreen.screens.first else { return }
        var mouseLoc = NSEvent.mouseLocation
        mouseLoc.x = NSWidth(screen.frame) - mouseLoc.x + 100
        mouseLoc.y = NSHeight(screen.frame) - mouseLoc.y + 100
        CGDisplayMoveCursorToPoint(0, CGPoint(x: mouseLoc.x, y: mouseLoc.y))
    }
}
