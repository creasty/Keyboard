import Cocoa

protocol EventManagerType {
    func register(_ handler: Handler)
    func handle(cgEvent: CGEvent) -> Unmanaged<CGEvent>?
}

final class EventManager: EventManagerType {
    private var handlers: [Handler] = []

    init() {
    }

    func register(_ handler: Handler) {
        handlers.append(handler)
    }

    func handle(cgEvent: CGEvent) -> Unmanaged<CGEvent>? {
        guard !Emitter.checkAndRemoveNoremapFlag(cgEvent: cgEvent) else {
            return Unmanaged.passRetained(cgEvent)
        }
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
        for handler in handlers {
            if let action = handler.handle(keyEvent: keyEvent) {
                return action
            }
        }

        return nil
    }
}
