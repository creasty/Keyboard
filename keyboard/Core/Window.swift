import Cocoa

enum WindowSize {
    case full
    case left
    case top
    case right
    case bottom
    case topLeft
    case topRight
    case bottomRight
    case bottomLeft

    func rect() -> CGRect? {
        guard let screen = NSScreen.main else {
            return nil
        }

        var frame = CGRect(origin: .zero, size: screen.frame.size)

        switch self {
        case .full:
            break
        case .left:
            frame.size.width = screen.frame.width / 2
        case .top:
            frame.size.height = screen.frame.height / 2
        case .right:
            frame.origin.x = screen.frame.width / 2
            frame.size.width = screen.frame.width / 2
        case .bottom:
            frame.origin.y = screen.frame.height / 2
            frame.size.height = screen.frame.height / 2
        case .topLeft:
            frame.size.height = screen.frame.height / 2
            frame.size.width = screen.frame.width / 2
        case .topRight:
            frame.origin.x = screen.frame.width / 2
            frame.size.height = screen.frame.height / 2
            frame.size.width = screen.frame.width / 2
        case .bottomLeft:
            frame.origin.y = screen.frame.height / 2
            frame.size.height = screen.frame.height / 2
            frame.size.width = screen.frame.width / 2
        case .bottomRight:
            frame.origin.y = screen.frame.height / 2
            frame.origin.x = screen.frame.width / 2
            frame.size.height = screen.frame.height / 2
            frame.size.width = screen.frame.width / 2
        }

        return frame
    }
}
