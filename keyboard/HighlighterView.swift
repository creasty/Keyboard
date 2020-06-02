import Cocoa

class HighlighterView: NSView {
    struct Const {
        static let size: CGFloat = 32
        static let color = NSColor(calibratedRed: 0, green: 0.7, blue: 1.0, alpha: 0.7)
    }

    var location: CGPoint?

    override func draw(_ dirtyRect: NSRect) {
        guard let location = location else { return }

        let rect = NSMakeRect(
            location.x - Const.size / 2,
            location.y - Const.size / 2,
            Const.size,
            Const.size
        )
        let path = NSBezierPath(roundedRect: rect, xRadius: Const.size, yRadius: Const.size)
        Const.color.set()
        path.fill()
        path.appendRect(dirtyRect)
    }
}
