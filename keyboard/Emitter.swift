import Cocoa

struct Emitter {
    struct Const {
        static let noremapFlag: CGEventFlags = .maskAlphaShift
        static let pauseInterval: UInt32 = 1000
    }

    enum Action {
        case down
        case up
        case both

        fileprivate func keyDowns() -> [Bool] {
            switch self {
            case .down:
                return [true]
            case .up:
                return [false]
            case .both:
                return [true, false]
            }
        }
    }

    func emit(key: KeyCode, flags: CGEventFlags = [], action: Action = .both) {
        action.keyDowns().forEach {
            if !$0 && action == .both {
                usleep(Const.pauseInterval)
            }

            let e = CGEvent(
                keyboardEventSource: nil,
                virtualKey: key.rawValue,
                keyDown: $0
            )
            e?.flags = flags.union(Const.noremapFlag)
            e?.post(tap: .cghidEventTap)
        }
    }
}
