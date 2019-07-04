import Cocoa

final class AppQuithHandler: Handler {
    private let repeatedKey = RepeatedKey()

    func handle(keyEvent: KeyEvent) -> HandlerAction? {
        guard keyEvent.isDown else {
            return nil
        }
        guard keyEvent.match(code: .q, command: true) else {
            return nil
        }

        if repeatedKey.match(at: 2) {
            return .passThrough
        }

        return .prevent
    }

    func handleSuperKey(prefix: KeyCode, keys: Set<KeyCode>) -> Bool {
        return false
    }
}
