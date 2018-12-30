import Foundation

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

    func rect(screenFrame: CGRect) -> CGRect {
        var frame = screenFrame

        switch self {
        case .full:
            break
        case .left:
            frame.size.width = screenFrame.width / 2
        case .top:
            frame.size.height = screenFrame.height / 2
        case .right:
            frame.origin.x += screenFrame.width / 2
            frame.size.width = screenFrame.width / 2
        case .bottom:
            frame.origin.y += screenFrame.height / 2
            frame.size.height = screenFrame.height / 2
        case .topLeft:
            frame.size.height = screenFrame.height / 2
            frame.size.width = screenFrame.width / 2
        case .topRight:
            frame.origin.x += screenFrame.width / 2
            frame.size.height = screenFrame.height / 2
            frame.size.width = screenFrame.width / 2
        case .bottomLeft:
            frame.origin.y += screenFrame.height / 2
            frame.size.height = screenFrame.height / 2
            frame.size.width = screenFrame.width / 2
        case .bottomRight:
            frame.origin.y += screenFrame.height / 2
            frame.origin.x += screenFrame.width / 2
            frame.size.height = screenFrame.height / 2
            frame.size.width = screenFrame.width / 2
        }

        return frame
    }
}
