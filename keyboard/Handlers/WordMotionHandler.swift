import Cocoa

// Word motions:
//
//     A+D    Delete word after cursor
//     A+H    Delete word before cursor
//     A+B    Move cursor backward by word
//     A+F    Move cursor forward by word
//
final class WordMotionHandler: Handler {
    struct Const {
        static let superKey: KeyCode = .a
    }
    
    private let workspace: NSWorkspace
    private let emitter: EmitterType
    
    init(workspace: NSWorkspace, emitter: EmitterType) {
        self.workspace = workspace
        self.emitter = emitter
    }

    func activateSuperKeys() -> [KeyCode] {
        return [Const.superKey]
    }
    
    func handle(keyEvent: KeyEvent) -> HandlerAction? {
        return nil
    }

    func handleSuperKey(prefix: KeyCode, keys: Set<KeyCode>) -> Bool {
        guard prefix == Const.superKey else { return false }

        switch keys {
        case [.d]:
            emitter.emit(code: .forwardDelete, flags: .maskAlternate)
            return true
        case [.h]:
            emitter.emit(code: .backspace, flags: .maskAlternate)
            return true
        case [.b]:
            emitter.emit(code: .leftArrow, flags: .maskAlternate)
            return true
        case [.f]:
            emitter.emit(code: .rightArrow, flags: .maskAlternate)
            return true
        default:
            break
        }

        return false
    }
}
