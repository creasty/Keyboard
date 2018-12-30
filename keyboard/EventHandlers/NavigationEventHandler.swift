import Cocoa

// Window/Space navigations:
//
//     S+H   Move to left space
//     S+L   Move to right space
//     S+J   Switch to next application
//     S+K   Switch to previous application
//     S+N   Switch to next window
//     S+B   Switch to previous window
//
final class NavigationEventHandler: EventHandler {
    private lazy var superKeyHandler: SuperKeyHandler = {
        return SuperKeyHandler(key: .s) { [weak self] (key) in
            self?.execute(key: key)
        }
    }()

    private let emitter = Emitter()

    func handle(key: KeyCode, flags: NSEvent.ModifierFlags, isKeyDown: Bool, isARepeat: Bool) -> EventHandlerAction? {
        return superKeyHandler.handle(key: key, flags: flags, isKeyDown: isKeyDown, isARepeat: isARepeat)
    }

    private func execute(key: KeyCode) {
        switch key {
        case .h:
            emitter.emit(key: .leftArrow, flags: [.maskControl, .maskSecondaryFn])
        case .j:
            emitter.emit(key: .tab, flags: [.maskCommand])
        case .k:
            emitter.emit(key: .tab, flags: [.maskCommand, .maskShift])
        case .l:
            emitter.emit(key: .rightArrow, flags: [.maskControl, .maskSecondaryFn])
        case .n:
            emitter.emit(key: .backtick, flags: [.maskCommand])
        case .b:
            emitter.emit(key: .backtick, flags: [.maskCommand, .maskShift])
        default:
            break
        }
    }
}
