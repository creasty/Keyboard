import Cocoa

enum HandlerAction {
    case prevent
    case passThrough
}

protocol Handler {
    func activateSuperKeys() -> [KeyCode]
    func handle(keyEvent: KeyEvent) -> HandlerAction?
    func handleSuperKey(prefix: KeyCode, keys: Set<KeyCode>) -> Bool
}

extension Handler {
    func activateSuperKeys() -> [KeyCode] {
        return []
    }
}
