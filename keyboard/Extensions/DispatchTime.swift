import Cocoa

extension DispatchTime {
    static func uptimeNanoseconds() -> Double {
        return Double(now().uptimeNanoseconds)
    }
}
