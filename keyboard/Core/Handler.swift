import Cocoa

enum HandlerAction {
    case prevent
    case passThrough
}

protocol Handler {
    func handle(keyEvent: KeyEvent) -> HandlerAction?
    func handleSuperKey(prefix: KeyCode, keys: Set<KeyCode>) -> Bool
}
