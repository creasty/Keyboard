import Cocoa

protocol EmitterType {
    func emit(key: KeyCode)
    func emit(key: KeyCode, flags: CGEventFlags)
    func emit(key: KeyCode, action: Emitter.Action)
    func emit(key: KeyCode, flags: CGEventFlags, action: Emitter.Action)
}

struct Emitter: EmitterType {
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

    static func checkAndRemoveNoremapFlag(cgEvent: CGEvent) -> Bool {
        if cgEvent.flags.contains(Const.noremapFlag) {
            cgEvent.flags.remove(Const.noremapFlag)
            return true
        }
        return false
    }

    func emit(key: KeyCode) {
        emit(key: key, flags: [], action: .both)
    }

    func emit(key: KeyCode, flags: CGEventFlags) {
        emit(key: key, flags: flags, action: .both)
    }

    func emit(key: KeyCode, action: Action) {
        emit(key: key, flags: [], action: action)
    }

    func emit(key: KeyCode, flags: CGEventFlags, action: Action) {
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
