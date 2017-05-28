import Foundation

final class KeySequence {
    private let threshold: Double = 300 * 1e6

    private struct Record {
        let timestamp: Double
        let count: Int

        init(count: Int = 1) {
            timestamp = Double(DispatchTime.now().uptimeNanoseconds)
            self.count = count
        }
    }

    private var records = [String:Record]()

    func count(forKey key: String) -> Int {
        guard let record = records[key] else {
            return 0
        }

        let t = Double(DispatchTime.now().uptimeNanoseconds)
        guard t - record.timestamp < threshold else {
            records[key] = nil
            return 0
        }

        return record.count
    }

    func record(forKey key: String) -> Int {
        let n = count(forKey: key) + 1
        records[key] = Record(count: n)
        return n
    }

    func reset(forKey key: String) {
        records[key] = nil
    }
}
