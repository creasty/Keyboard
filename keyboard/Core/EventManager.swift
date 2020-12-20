import Cocoa

protocol EventManagerType {
    func register(handler: Handler)
    func handle(proxy: CGEventTapProxy, cgEvent: CGEvent) -> Unmanaged<CGEvent>?
}

final class EventManager: EventManagerType {
    private let emitter: EmitterType

    private var handlers = [Handler]()
    private let superKey = SuperKey()
    private var superKeyPrefixes = Set<KeyCode>()

    init(emitter: EmitterType) {
        self.emitter = emitter
    }

    func register(handler: Handler) {
        handlers.append(handler)

        handler.activateSuperKeys().forEach {
            superKeyPrefixes.insert($0)
        }
    }

    func handle(proxy: CGEventTapProxy, cgEvent: CGEvent) -> Unmanaged<CGEvent>? {
        emitter.setProxy(proxy)

        guard let event = NSEvent(cgEvent: cgEvent) else {
            return Unmanaged.passUnretained(cgEvent)
        }
        guard let keyEvent = KeyEvent(nsEvent: event) else {
            return Unmanaged.passUnretained(cgEvent)
        }

        let action = updateSuperKey(keyEvent: keyEvent)
            ?? handleSuperKey(keyEvent: keyEvent)
            ?? handle(keyEvent: keyEvent)
            ?? .passThrough

        switch action {
        case .prevent:
            return nil
        case .passThrough:
            return Unmanaged.passUnretained(cgEvent)
        }
    }
}

extension EventManager: Handler {
    func handle(keyEvent: KeyEvent) -> HandlerAction? {
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

private extension EventManager {
    func updateSuperKey(keyEvent: KeyEvent) -> HandlerAction? {
        guard keyEvent.match() else {
            superKey.inactivate()
            return nil
        }

        if superKeyPrefixes.contains(keyEvent.code) {
            // Activte the mode
            if keyEvent.isDown, superKey.activate(prefixKey: keyEvent.code) {
                return .prevent
            }

            if let prefixKey = superKey.prefixKey, prefixKey == keyEvent.code {
                // Cancel on the final keyup
                if !keyEvent.isDown && !keyEvent.isARepeat {
                    switch superKey.state {
                    case .activated:
                        emitter.emit(keyCode: prefixKey, flags: [], action: .both)
                    case .used, .enabled:
                        // Abort a pending operation if any
                        if let pendingKey = superKey.cancel() {
                            emitter.emit(keyCode: prefixKey, flags: [], action: .both)
                            emitter.emit(keyCode: pendingKey, flags: [], action: .both)
                        } else {
                            // Trigger any key events to clean up
                            emitter.emit(keyCode: .command, flags: [], action: .both)
                        }
                    default: break
                    }

                    // Restore the state
                    superKey.inactivate()
                }

                // Always ignore the prefix key
                return .prevent
            }
        }

        // Disable when another key was pressed immediately after the activation
        if keyEvent.isDown, !superKey.enable() {
            if let prefixKey = superKey.prefixKey {
                emitter.emit(keyCode: prefixKey, flags: [], action: .both)
            }
            emitter.emit(keyCode: keyEvent.code, flags: [], action: .down)

            return .prevent
        }

        return nil
    }

    func handleSuperKey(keyEvent: KeyEvent) -> HandlerAction? {
        guard superKey.isEnabled, let prefixKey = superKey.prefixKey else {
            return nil
        }
        guard keyEvent.match() else {
            return nil
        }

        superKey.perform(key: keyEvent.code, isKeyDown: keyEvent.isDown) { [weak self] (keys) in
            self?.handleSuperKey(prefix: prefixKey, keys: keys)
        }

        return .prevent
    }
}
