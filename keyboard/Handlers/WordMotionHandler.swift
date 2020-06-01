import Cocoa

// Word motions:
//
//     A+D    Delete word after cursor
//     A+H    Delete word before cursor
//     A+B    Move cursor backward by word
//     A+F    Move cursor forward by word
//
final class WordMotionHandler: Handler {
    private let workspace: NSWorkspace
    private let emitter: EmitterType

    init(workspace: NSWorkspace, emitter: EmitterType) {
        self.workspace = workspace
        self.emitter = emitter
    }

    func activateSuperKeys() -> [KeyCode] {
        return [.a]
    }
    
    func handle(keyEvent: KeyEvent) -> HandlerAction? {
        return nil
    }

    func handleSuperKey(prefix: KeyCode, keys: Set<KeyCode>) -> Bool {
        guard prefix == .a else { return false }

        switch keys {
        case [.d]:
            emitter.emit(code: .forwardDelete, flags: .maskAlternate)
        case [.h]:
            emitter.emit(code: .backspace, flags: .maskAlternate)
        case [.b]:
            emitter.emit(code: .leftArrow, flags: .maskAlternate)
        case [.f]:
            emitter.emit(code: .rightArrow, flags: .maskAlternate)
        default:
            break
        }

        return false
    }
}
