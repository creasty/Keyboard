import Cocoa

protocol EventManagerType {
    func register(handler: Handler)
    func handle(proxy: CGEventTapProxy, cgEvent: CGEvent) -> Unmanaged<CGEvent>?
}

final class EventManager: EventManagerType {
    private let emitter: EmitterType

    private var handlers: [Handler] = []
    private var superKeys: [KeyCode: SuperKey] = [:]

    init(emitter: EmitterType) {
        self.emitter = emitter
    }

    func register(handler: Handler) {
        handlers.append(handler)

        handler.activateSuperKeys().forEach {
            if superKeys[$0] == nil {
                superKeys[$0] = SuperKey(prefix: $0)
            }
        }
    }

    func handle(proxy: CGEventTapProxy, cgEvent: CGEvent) -> Unmanaged<CGEvent>? {
        emitter.setProxy(proxy)

        guard let event = NSEvent(cgEvent: cgEvent) else {
            return Unmanaged.passRetained(cgEvent)
        }
        guard let keyEvent = KeyEvent(nsEvent: event) else {
            return Unmanaged.passRetained(cgEvent)
        }

        let action = handle(keyEvent: keyEvent) ?? .passThrough

        switch action {
        case .prevent:
            return nil
        case .passThrough:
            return Unmanaged.passRetained(cgEvent)
        }
    }
}

extension EventManager: Handler {
    func handle(keyEvent: KeyEvent) -> HandlerAction? {
        for (_, superKey) in superKeys {
            if let action = updateState(superKey: superKey, keyEvent: keyEvent) {
                return action
            }
            if let action = execute(superKey: superKey, keyEvent: keyEvent) {
                return action
            }
        }

        for handler in handlers {
            if let action = handler.handle(keyEvent: keyEvent) {
                return action
            }
        }

        return nil
    }

    @discardableResult
    func handleSuperKey(prefix: KeyCode, keys: Set<KeyCode>) -> Bool {
        for handler in handlers {
            if handler.handleSuperKey(prefix: prefix, keys: keys) {
                return true
            }
        }

        return false
    }
}

extension EventManager {
    private func updateState(superKey: SuperKey, keyEvent: KeyEvent) -> HandlerAction? {
        guard keyEvent.match() else {
            superKey.state = .inactive
            return nil
        }

        if keyEvent.code == superKey.prefix {
            guard !keyEvent.isARepeat else {
                return .prevent
            }
            guard !keyEvent.isDown else {
                superKey.state = .activated
                return .prevent
            }

            switch superKey.state {
            case .activated:
                emitter.emit(code: superKey.prefix)
            case .used, .enabled:
                if let key = superKey.cancel() {
                    emitter.emit(code: superKey.prefix)
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

            emitter.emit(code: superKey.prefix)
            emitter.emit(code: keyEvent.code, action: (keyEvent.isDown ? .down : .up))

            return .prevent
        }

        return nil
    }

    private func execute(superKey: SuperKey, keyEvent: KeyEvent) -> HandlerAction? {
        guard superKey.isEnabled else {
            return nil
        }
        guard keyEvent.match() else {
            return nil
        }

        superKey.perform(key: keyEvent.code, isKeyDown: keyEvent.isDown) { [weak self] (keys) in
            self?.handleSuperKey(prefix: superKey.prefix, keys: keys)
        }

        return .prevent
    }
}
