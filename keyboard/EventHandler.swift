import Cocoa

enum HandlerAction {
    case prevent
    case passThrough
}

protocol Handler {
    func handle(key: KeyCode, flags: NSEvent.ModifierFlags, isKeyDown: Bool, isARepeat: Bool) -> HandlerAction?
}
