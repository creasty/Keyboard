import Cocoa

// Switch to EISUU with Escape key
final class EscapeEventHandler: EventHandler {
    private let emitter = Emitter()

    func handle(key: KeyCode, flags: NSEvent.ModifierFlags, isKeyDown: Bool, isARepeat: Bool) -> EventHandlerAction? {
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
}
