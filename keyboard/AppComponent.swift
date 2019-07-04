import Cocoa

final class AppComponent {
    private(set) lazy var emitter: EmitterType = Emitter()

    let nsWorkspace = NSWorkspace.shared

    func navigationHandler() -> Handler {
        return NavigationHandler(workspace: nsWorkspace, emitter: emitter)
    }

    func emacsHandler() -> Handler {
        return EmacsHandler(workspace: nsWorkspace, emitter: emitter)
    }

    func escapeHandler() -> Handler {
        return EscapeHandler(emitter: emitter)
    }

    func windowResizeHandler() -> Handler {
        return WindowResizeHandler(workspace: nsWorkspace)
    }

    func appSwitchHandler() -> Handler {
        return AppSwitchHandler(workspace: nsWorkspace, emitter: emitter)
    }

    func inputMethodHandler() -> Handler {
        return InputSourceHandler(emitter: emitter)
    }

    func appQuithHandler() -> Handler {
        return AppQuithHandler()
    }

    func eventManager() -> EventManagerType {
        let eventManager: EventManagerType = EventManager(emitter: emitter)
        eventManager.register(handler: navigationHandler())
        eventManager.register(handler: emacsHandler())
        eventManager.register(handler: escapeHandler())
        eventManager.register(handler: windowResizeHandler())
        eventManager.register(handler: appSwitchHandler())
        eventManager.register(handler: inputMethodHandler())
        eventManager.register(handler: appQuithHandler())
        return eventManager
    }
}
