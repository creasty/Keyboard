import Cocoa
import InputMethodKit

// Input Method switching
//
//     J+K Select next source
//
final class InputMethodHandler: Handler {
    private let emitter: EmitterType
    private let inputSources: [TISInputSource]

    init(emitter: EmitterType) {
        self.emitter = emitter

        let inputSourceNSArray = TISCreateInputSourceList(nil, false).takeRetainedValue() as NSArray
        let inputSourceList = inputSourceNSArray as! [TISInputSource]
        self.inputSources = inputSourceList.filter { $0.isKeyboardInputSource && $0.isSelectable }
    }

    func activateSuperKeys() -> [KeyCode] {
        return [.f]
    }

    func handle(keyEvent: KeyEvent) -> HandlerAction? {
        return nil
    }

    func handleSuperKey(prefix: KeyCode, keys: Set<KeyCode>) -> Bool {
        guard prefix == .f else { return false }

        switch keys {
        case [.j]:
            changeInput()
            return true
        default:
            return false
        }
    }

    private func changeInput() {
        guard let i = inputSources.firstIndex(where: { $0.isSelected }) else { return }
        let next = inputSources[(i + 1) % inputSources.count]
        TISSelectInputSource(next)
    }
}
