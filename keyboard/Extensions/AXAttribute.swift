import Cocoa

struct AXAttribute<T> {
    let key: String

    init(_ key: String) {
        self.key = key
    }
}

struct AXAttributes {
    static let frame = AXAttribute<CGRect>("AXFrame")
    static let position = AXAttribute<CGPoint>("AXPosition")
    static let size = AXAttribute<CGSize>("AXSize")
    static let windows = AXAttribute<[AXUIElement]>("AXWindows")
    static let focusedWindow = AXAttribute<AXUIElement>("AXFocusedWindow")
}
