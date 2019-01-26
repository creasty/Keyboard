import Cocoa

class SuperKeyHandler: Handler {
    private let superKey: SuperKey
    private let emitter: EmitterType

    init(key: KeyCode, emitter: EmitterType) {
        superKey = SuperKey(key: key)
        self.emitter = emitter
    }

    func handle(keyEvent: KeyEvent) -> HandlerAction? {
        return updateState(keyEvent: keyEvent)
            ?? execute(keyEvent: keyEvent)
    }

    private func updateState(keyEvent: KeyEvent) -> HandlerAction? {
        guard keyEvent.match() else {
            superKey.state = .inactive
            return nil
        }

        if keyEvent.code == superKey.prefixKey {
            guard !keyEvent.isARepeat else {
                return .prevent
            }
            guard !keyEvent.isDown else {
                superKey.state = .activated
                return .prevent
            }

            switch superKey.state {
            case .activated:
                emitter.emit(code: superKey.prefixKey)
            case .used, .enabled:
                if let key = superKey.cancel() {
                    emitter.emit(code: superKey.prefixKey)
                    emitter.emit(code: key)
                } else {
                    emitter.emit(code: .command)
                }
            default: break
            }

            superKey.state = .inactive
            return .prevent
        }

        guard keyEvent.isDown else {
            return nil
        }

        guard superKey.enable() else {
            superKey.state = .disabled

            emitter.emit(code: superKey.prefixKey)
            emitter.emit(code: keyEvent.code, action: (keyEvent.isDown ? .down : .up))

            return .prevent
        }

        return nil
    }

    private func execute(keyEvent: KeyEvent) -> HandlerAction? {
        guard superKey.isEnabled else {
            return nil
        }
        guard keyEvent.match() else {
            return nil
        }

        superKey.perform(key: keyEvent.code, isKeyDown: keyEvent.isDown) { [weak self] (keys) in
            self?.execute(keys: keys)
        }

        return .prevent
    }

    func execute(keys: Set<KeyCode>) {
        fatalError("Not implemented")
    }
}
