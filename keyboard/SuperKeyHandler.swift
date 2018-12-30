import Cocoa

final class SuperKeyHandler: EventHandler {
    private let superKey: SuperKey
    private let callback: (KeyCode) -> Void

    private let emitter = Emitter()

    init(key: KeyCode, callback: @escaping (KeyCode) -> Void) {
        superKey = SuperKey(key: key)
        self.callback = callback
    }

    func handle(key: KeyCode, flags: NSEvent.ModifierFlags, isKeyDown: Bool, isARepeat: Bool) -> EventHandlerAction? {
        return updateState(key: key, flags: flags, isKeyDown: isKeyDown, isARepeat: isARepeat)
            ?? execute(key: key, flags: flags, isKeyDown: isKeyDown)
    }

    private func updateState(key: KeyCode, flags: NSEvent.ModifierFlags, isKeyDown: Bool, isARepeat: Bool) -> EventHandlerAction? {
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

    private func execute(key: KeyCode, flags: NSEvent.ModifierFlags, isKeyDown: Bool) -> EventHandlerAction? {
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

            self?.callback(key)
        }

        return .prevent
    }
}
