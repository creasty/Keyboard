import Foundation

final class RepeatedKey {
    private let threshold: Double = 300 * 1e6

    private var state: (count: Int, timestamp: Double)?

    func count() -> Int {
        guard let state = state else {
            return 0
        }

        guard now() - state.timestamp < threshold else {
            self.state = nil
            return 0
        }

        return state.count
    }

    func record() -> Int {
        let n = count() + 1
        self.state = (count: n, timestamp: now())
        return n
    }

    func reset() {
        state = nil
    }

    func match(at exactCount: Int) -> Bool {
        if record() == exactCount {
            reset()
            return true
        }
        return false
    }

    private func now() -> Double {
        return DispatchTime.uptimeNanoseconds()
    }
}
