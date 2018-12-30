import Cocoa

enum EventHandlerAction {
    case prevent
    case passThrough
}

protocol EventHandler {
    func handle(key: KeyCode, flags: NSEvent.ModifierFlags, isKeyDown: Bool, isARepeat: Bool) -> EventHandlerAction?
}
