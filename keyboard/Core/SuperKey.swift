import Foundation

final class SuperKey {
    let hookedKey: KeyCode

    enum State {
        case inactive
        case activated
        case enabled
        case disabled
    }

    private let threshold: Double = 80 * 1e6
    private var activatedAt: Double = 0

    var state: State = .inactive {
        didSet {
            guard state != oldValue else {
                return
            }

            if state == .activated {
                activatedAt = DispatchTime.uptimeNanoseconds()
            }

            #if true
                NSLog("state = %@", String(describing: state))
            #endif
        }
    }

    init(key: KeyCode) {
        hookedKey = key
    }

    func canBeEnabled() -> Bool {
        return DispatchTime.uptimeNanoseconds() - activatedAt > threshold
    }
}
