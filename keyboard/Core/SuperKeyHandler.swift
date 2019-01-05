import Cocoa

class SuperKeyHandler: Handler {
    private let superKey: SuperKey
    private let emitter: EmitterType

    init(key: KeyCode, emitter: EmitterType) {
        superKey = SuperKey(key: key)
        self.emitter = emitter
    }

    func handle(key: KeyCode, flags: NSEvent.ModifierFlags, isKeyDown: Bool, isARepeat: Bool) -> HandlerAction? {
        return updateState(key: key, flags: flags, isKeyDown: isKeyDown, isARepeat: isARepeat)
            ?? execute(key: key, flags: flags, isKeyDown: isKeyDown)
    }

    private func updateState(key: KeyCode, flags: NSEvent.ModifierFlags, isKeyDown: Bool, isARepeat: Bool) -> HandlerAction? {
        guard flags.match() else {
            superKey.state = .inactive
            return nil
        }

        if key == superKey.prefixKey {
            guard !isARepeat else {
                return .prevent
            }
            guard !isKeyDown else {
                superKey.state = .activated
                return .prevent
            }

            switch superKey.state {
            case .activated:
                emitter.emit(key: superKey.prefixKey)
            case .used, .enabled:
                if let key = superKey.cancel() {
                    emitter.emit(key: superKey.prefixKey)
                    emitter.emit(key: key)
                } else {
                    emitter.emit(key: .command)
                }
            default: break
            }

            superKey.state = .inactive
            return .prevent
        }

        guard isKeyDown else {
            return nil
        }

        guard superKey.enable() else {
            superKey.state = .disabled

            emitter.emit(key: superKey.prefixKey)
            emitter.emit(key: key, action: (isKeyDown ? .down : .up))

            return .prevent
        }

        return nil
    }

    private func execute(key: KeyCode, flags: NSEvent.ModifierFlags, isKeyDown: Bool) -> HandlerAction? {
        guard superKey.isEnabled else {
            return nil
        }
        guard flags.match() else {
            return nil
        }

        superKey.perform(key: key) { [weak self] in
            guard isKeyDown else {
                return
            }

            self?.execute(key: key)
        }

        return .prevent
    }

    func execute(key: KeyCode) {
        fatalError("Not implemented")
    }
}
