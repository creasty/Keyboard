import Cocoa

private enum WindowSize {
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

// Window resizer:
//
//     S+D+F  Full
//     S+D+H  Left
//     S+D+J  Bottom
//     S+D+K  Top
//     S+D+L  Right
//
//           Cmd-Alt-/        Full
//           Cmd-Alt-Left     Left
//           Cmd-Alt-Up       Top
//           Cmd-Alt-Right    Right
//           Cmd-Alt-Down     Bottom
//     Shift-Cmd-Alt-Left     Top-left
//     Shift-Cmd-Alt-Up       Top-right
//     Shift-Cmd-Alt-Right    Bottom-right
//     Shift-Cmd-Alt-Down     Bottom-left
//
final class WindowResizeHandler: Handler {
    private let workspace: NSWorkspace

    init(workspace: NSWorkspace) {
        self.workspace = workspace
    }

    func activateSuperKeys() -> [KeyCode] {
        return [.s]
    }

    func handle(keyEvent: KeyEvent) -> HandlerAction? {
//        guard keyEvent.isDown else {
//            return nil
//        }
//        guard keyEvent.match(shift: nil, option: true, command: true) else {
//            return nil
//        }
//
//        var windowSize: WindowSize?
//
//        if keyEvent.shift {
//            switch keyEvent.code {
//            case .leftArrow:  windowSize = .topLeft
//            case .upArrow:    windowSize = .topRight
//            case .rightArrow: windowSize = .bottomRight
//            case .downArrow:  windowSize = .bottomLeft
//            default: break
//            }
//        } else {
//            switch keyEvent.code {
//            case .slash:      windowSize = .full
//            case .leftArrow:  windowSize = .left
//            case .upArrow:    windowSize = .top
//            case .rightArrow: windowSize = .right
//            case .downArrow:  windowSize = .bottom
//            default: break
//            }
//        }
//
//        if let windowSize = windowSize {
//            do {
//                try resizeWindow(windowSize: windowSize)
//            } catch {
//                print(error)
//            }
//
//            return .prevent
//        }

        return nil
    }

    func handleSuperKey(prefix: KeyCode, keys: Set<KeyCode>) -> Bool {
        guard prefix == .s else { return false }

        var windowSize: WindowSize?
        switch keys {
        case [.d, .f]: windowSize = .full
        case [.d, .h]: windowSize = .left
        case [.d, .k]: windowSize = .top
        case [.d, .l]: windowSize = .right
        case [.d, .j]: windowSize = .bottom
        default: break
        }

        if let windowSize = windowSize {
            do {
                try resizeWindow(windowSize: windowSize)
            } catch {
                print(error)
            }

            return true
        }

        return false
    }

    private func resizeWindow(windowSize: WindowSize) throws {
        guard let app = workspace.frontmostApplication?.axUIElement() else { return }
        guard let window = try app.getAttribute(AXAttributes.focusedWindow) else { return }
        guard let frame = try window.getAttribute(AXAttributes.frame) else { return }

        guard let screen = (NSScreen.screens
            .map { screen in (screen, screen.frame.intersection(frame)) }
            .filter { _, intersect in !intersect.isNull }
            .map { screen, intersect in (screen, intersect.size.width * intersect.size.height) }
            .max { lhs, rhs in lhs.1 < rhs.1 }?
            .0
        ) else {
            return
        }

        let newFrame = windowSize.rect(screenFrame: screen.frame)

        try window.setAttribute(AXAttributes.position, value: newFrame.origin)
        try window.setAttribute(AXAttributes.size, value: newFrame.size)
    }
}
