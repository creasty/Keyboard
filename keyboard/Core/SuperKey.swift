import Foundation

final class SuperKey {
    let hookedKey: KeyCode

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

    private var handledAction: DispatchWorkItem?
    private var handledKey: KeyCode?
    private var handledAt: DispatchTime?

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
        hookedKey = key
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

    func perform(key: KeyCode, block: @escaping @convention(block) () -> Void) {
        let dispatchTime: DispatchTime = DispatchTime.now() + DispatchTimeInterval.milliseconds(dispatchDelay)

        handledKey = key
        handledAt = dispatchTime

        guard state == .used else {
            handledAction = nil
            block()
            return
        }
        state = .used

        let work = DispatchWorkItem(block: block)
        handledAction = work
        DispatchQueue.global().asyncAfter(deadline: dispatchTime, execute: work)
    }

    func cancel() -> KeyCode? {
        guard let handledKey = handledKey, let handledAt = handledAt else {
            return nil
        }
        self.handledKey = nil
        self.handledAt = nil

        guard handledAt > DispatchTime.now() else {
            self.handledAction = nil
            return nil
        }

        if let handledAction = handledAction {
            self.handledAction = nil
            handledAction.cancel()
        }

        return handledKey
    }
}
