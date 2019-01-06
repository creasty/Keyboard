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
        guard let key = KeyCode(rawValue: event.keyCode) else {
            return Unmanaged.passRetained(cgEvent)
        }

        let flags = event.modifierFlags
        let isKeyDown = (event.type == .keyDown)

        let finalAction: HandlerAction = {
            for handler in handlers {
                if let action = handler.handle(key: key, flags: flags, isKeyDown: isKeyDown, isARepeat: event.isARepeat) {
                    return action
                }
            }

            return .passThrough
        }()

        switch finalAction {
        case .prevent:
            return nil
        case .passThrough:
            return Unmanaged.passRetained(cgEvent)
        }
    }
}
