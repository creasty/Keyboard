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
final class NavigationHandler: Handler {
    private let emitter: Emitter

    init(emitter: Emitter) {
        self.emitter = emitter
    }

    private lazy var superKeyHandler: SuperKeyHandler = {
        return SuperKeyHandler(key: .s, emitter: emitter) { [weak self] (key) in
            self?.execute(key: key)
        }
    }()

    func handle(key: KeyCode, flags: NSEvent.ModifierFlags, isKeyDown: Bool, isARepeat: Bool) -> HandlerAction? {
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
            emitter.emit(key: .f1, flags: [.maskCommand])
        case .b:
            emitter.emit(key: .f1, flags: [.maskCommand, .maskShift])
        default:
            break
        }
    }
}
