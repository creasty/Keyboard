import Foundation

final class SuperKey {
    struct Const {
        static let downThresholdMs: Double = 50
        static let dispatchDelayMs: Int = 150
    }

    enum State {
        case inactive
        case activated
        case enabled
        case used
        case disabled
    }

    private var activatedAt: Double = 0
    private var current: (key: KeyCode, time: DispatchTime, work: DispatchWorkItem?)?

    var prefixKey: KeyCode?
    private var pressedKeys: Set<KeyCode> = []

    var state: State = .inactive {
        didSet {
            guard state != oldValue else {
                return
            }

            if state == .activated {
                activatedAt = DispatchTime.uptimeNanoseconds()
            }
        }
    }

    var isEnabled: Bool {
        return [.enabled, .used].contains(state)
    }

    func enable() -> Bool {
        guard state == .activated else {
            return true
        }
        guard DispatchTime.uptimeNanoseconds() - activatedAt > Const.downThresholdMs * 1e6 else {
            state = .disabled
            return false
        }
        state = .enabled
        return true
    }

    func perform(key: KeyCode, isKeyDown: Bool, block: @escaping (Set<KeyCode>) -> Void) {
        guard isKeyDown else {
            pressedKeys.remove(key)
            return
        }
        pressedKeys.insert(key)
        let keys = pressedKeys

        guard state != .used else {
            current = (key: key, time: DispatchTime.now(), work: nil)
            block(keys)
            return
        }
        state = .used

        let work = DispatchWorkItem() {
            block(keys)
        }
        let dispatchTime = DispatchTime.now() + DispatchTimeInterval.milliseconds(Const.dispatchDelayMs)
        current = (key: key, time: dispatchTime, work: work)
        DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: work)
    }

    func cancel() -> KeyCode? {
        guard let current = current else { return nil }
        self.current = nil

        prefixKey = nil
        pressedKeys = []

        guard current.time > DispatchTime.now() else { return nil }
        current.work?.cancel()

        return current.key
    }
}
