import Foundation

final class SuperKey {
    let prefixKey: KeyCode

    enum State {
        case inactive
        case activated
        case enabled
        case used
        case disabled
    }

    private let downThreshold: Double = 50 // ms
    private let dispatchDelay: Int = 150 // ms

    private var activatedAt: Double = 0
    private var current: (key: KeyCode, time: DispatchTime, work: DispatchWorkItem?)?

    private var pressedKeys: Set<KeyCode> = []

    var state: State = .inactive {
        didSet {
            guard state != oldValue else {
                return
            }

            if state == .activated {
                activatedAt = DispatchTime.uptimeNanoseconds()
            }

//            NSLog("state = %@", String(describing: state))
        }
    }

    var isEnabled: Bool {
        return [.enabled, .used].contains(state)
    }

    init(key: KeyCode) {
        prefixKey = key
    }

    func enable() -> Bool {
        guard state == .activated else {
            return true
        }
        guard DispatchTime.uptimeNanoseconds() - activatedAt > downThreshold * 1e6 else {
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
        let dispatchTime = DispatchTime.now() + DispatchTimeInterval.milliseconds(dispatchDelay)
        current = (key: key, time: dispatchTime, work: work)
        DispatchQueue.global().asyncAfter(deadline: dispatchTime, execute: work)
    }

    func cancel() -> KeyCode? {
        guard let current = current else {
            return nil
        }
        self.current = nil

        pressedKeys = []

        guard current.time > DispatchTime.now() else {
            return nil
        }

        current.work?.cancel()

        return current.key
    }
}
