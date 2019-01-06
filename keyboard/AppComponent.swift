import Cocoa

final class AppComponent {
    func emitter() -> EmitterType {
        return Emitter()
    }

    func nsWorkspace() -> NSWorkspace {
        return NSWorkspace.shared
    }

    func navigationHandler() -> Handler {
        return NavigationHandler(emitter: emitter())
    }

    func emacsHandler() -> Handler {
        return EmacsHandler(workspace: nsWorkspace(), emitter: emitter())
    }

    func escapeHandler() -> Handler {
        return EscapeHandler(emitter: emitter())
    }

    func windowResizeHandler() -> Handler {
        return WindowResizeHandler(workspace: nsWorkspace())
    }

    func appSwitchHandler() -> Handler {
        return AppSwitchHandler(workspace: nsWorkspace(), emitter: emitter())
    }

    func eventManager() -> EventManagerType {
        let eventManager: EventManagerType = EventManager()
        eventManager.register(navigationHandler())
        eventManager.register(emacsHandler())
        eventManager.register(escapeHandler())
        eventManager.register(windowResizeHandler())
        eventManager.register(appSwitchHandler())
        return eventManager
    }
}
