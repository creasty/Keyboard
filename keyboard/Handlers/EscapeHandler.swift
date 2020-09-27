import Cocoa

// Switch to EISUU with Escape key
final class EscapeHandler: Handler {
    private let emitter: EmitterType

    init(emitter: EmitterType) {
        self.emitter = emitter
    }

    func handle(keyEvent: KeyEvent) -> HandlerAction? {
        guard keyEvent.isDown else {
            return nil
        }
        guard isEscapeKey(keyEvent: keyEvent) else {
            return nil
        }

        emitter.emit(keyCode: .jisEisu, flags: [], action: .both)

        return .passThrough
    }

    func handleSuperKey(prefix: KeyCode, keys: Set<KeyCode>) -> Bool {
        return false
    }

    private func isEscapeKey(keyEvent: KeyEvent) -> Bool {
        if keyEvent.match(code: .escape) {
            return true
        }
        if keyEvent.match(code: .c, shift: false, control: true, option: false, command: false) {
            return true
        }
        return false
    }
}
