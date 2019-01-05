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
final class NavigationHandler: SuperKeyHandler {
    private let emitter: EmitterType

    init(emitter: EmitterType) {
        self.emitter = emitter
        super.init(key: .s, emitter: emitter)
    }

    override func execute(key: KeyCode) {
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
