import Cocoa

struct AXAttribute<T> {
    let key: String

    init(_ key: String) {
        self.key = key
    }
}

struct AXAttributes {
    static let frame = AXAttribute<CGRect>("AXFrame")
    static let position = AXAttribute<CGPoint>(kAXPositionAttribute)
    static let size = AXAttribute<CGSize>(kAXSizeAttribute)
    static let windows = AXAttribute<[AXUIElement]>(kAXWindowsAttribute)
    static let focusedWindow = AXAttribute<AXUIElement>(kAXFocusedWindowAttribute)
}
