import Cocoa

// Switch to EISUU with Escape key
final class EscapeHandler: Handler {
    private let emitter: Emitter

    init(emitter: Emitter) {
        self.emitter = emitter
    }

    func handle(key: KeyCode, flags: NSEvent.ModifierFlags, isKeyDown: Bool, isARepeat: Bool) -> HandlerAction? {
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
