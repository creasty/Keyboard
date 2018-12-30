import Cocoa

final class AppComponent {
    func emitter() -> Emitter {
        return Emitter()
    }

    func nsWorkspace() -> NSWorkspace {
        return NSWorkspace.shared
    }

    func navigationHandler() -> NavigationHandler {
        return NavigationHandler(emitter: emitter())
    }

    func emacsHandler() -> EmacsHandler {
        return EmacsHandler(workspace: nsWorkspace(), emitter: emitter())
    }

    func escapeHandler() -> EscapeHandler {
        return EscapeHandler(emitter: emitter())
    }

    func windowResizeHandler() -> WindowResizeHandler {
        return WindowResizeHandler(workspace: nsWorkspace())
    }

    func appOpenHandler() -> AppOpenHandler {
        return AppOpenHandler(workspace: nsWorkspace(), emitter: emitter())
    }

    func eventManager() -> EventManager {
        let eventManager = EventManager()
        eventManager.handlers = [
            navigationHandler(),
            emacsHandler(),
            escapeHandler(),
            windowResizeHandler(),
            appOpenHandler(),
        ]
        return eventManager
    }
}
