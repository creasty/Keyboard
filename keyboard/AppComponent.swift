import Cocoa

// Needs to be globally accesible
var _eventManager: EventManagerType?
var _eventTap: CFMachPort?

final class AppComponent {
    let nsWorkspace = NSWorkspace.shared
    let fileManager = FileManager.default

    let eventTapCallback: CGEventTapCallBack = { (proxy, type, event, _) in
        switch type {
        case .tapDisabledByTimeout:
            if let tap = _eventTap {
                CGEvent.tapEnable(tap: tap, enable: true) // Re-enable
            }
        case .keyUp, .keyDown:
            if let manager = _eventManager {
                return manager.handle(proxy: proxy, cgEvent: event)
            }
        default:
            break
        }
        return Unmanaged.passRetained(event)
    }

    private(set) var emitter: EmitterType = Emitter()

    func navigationHandler() -> Handler {
        return NavigationHandler(
            workspace: nsWorkspace,
            fileManager: fileManager,
            emitter: emitter
        )
    }

    func emacsHandler() -> Handler {
        return EmacsHandler(workspace: nsWorkspace, emitter: emitter)
    }
    
    func wordMotionHandler() -> Handler {
        return WordMotionHandler(workspace: nsWorkspace, emitter: emitter)
    }

    func escapeHandler() -> Handler {
        return EscapeHandler(emitter: emitter)
    }

    func windowResizeHandler() -> Handler {
        return WindowResizeHandler(workspace: nsWorkspace)
    }
    
    func cursorKeyHandler() -> Handler {
        return CursorKeyHandler(emitter: emitter)
    }

    func appSwitchHandler() -> Handler {
        return AppSwitchHandler(workspace: nsWorkspace)
    }

    func inputMethodHandler() -> Handler {
        return InputSourceHandler()
    }

    func appQuithHandler() -> Handler {
        return AppQuithHandler()
    }

    func eventManager() -> EventManagerType {
        let eventManager: EventManagerType = EventManager(emitter: emitter)
        eventManager.register(handler: navigationHandler())
        eventManager.register(handler: emacsHandler())
        eventManager.register(handler: wordMotionHandler())
        eventManager.register(handler: escapeHandler())
        eventManager.register(handler: windowResizeHandler())
        eventManager.register(handler: cursorKeyHandler())
        eventManager.register(handler: appSwitchHandler())
        eventManager.register(handler: inputMethodHandler())
        eventManager.register(handler: appQuithHandler())
        return eventManager
    }
}
