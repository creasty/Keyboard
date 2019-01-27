import Cocoa

// Window/Space navigations:
//
//     S+H   Move to left space
//     S+L   Move to right space
//     S+J   Switch to next application
//     S+K   Switch to previous application
//     S+N   Switch to next window
//     S+B   Switch to previous window
//     S+M   Mission Control
//
final class NavigationHandler: Handler {
    private let workspace: NSWorkspace
    private let emitter: EmitterType

    init(workspace: NSWorkspace, emitter: EmitterType) {
        self.workspace = workspace
        self.emitter = emitter
    }

    func activateSuperKeys() -> [KeyCode] {
        return [.s]
    }

    func handle(keyEvent: KeyEvent) -> HandlerAction? {
        return nil
    }

    func handleSuperKey(prefix: KeyCode, keys: Set<KeyCode>) -> Bool {
        guard prefix == .s else { return false }

        switch keys {
        case [.h]:
            emitter.emit(code: .leftArrow, flags: [.maskControl, .maskSecondaryFn])
            return true
        case [.j]:
            emitter.emit(code: .tab, flags: [.maskCommand])
            return true
        case [.k]:
            emitter.emit(code: .tab, flags: [.maskCommand, .maskShift])
            return true
        case [.l]:
            emitter.emit(code: .rightArrow, flags: [.maskControl, .maskSecondaryFn])
            return true
        case [.n]:
            emitter.emit(code: .f1, flags: [.maskCommand])
            return true
        case [.b]:
            emitter.emit(code: .f1, flags: [.maskCommand, .maskShift])
            return true
        case [.m]:
            showOrHideApplication(byBundleIdentifier: "com.apple.exposelauncher")
            return true
        default:
            return false
        }
    }

    private func showOrHideApplication(byBundleIdentifier id: String) {
        if let app = workspace.frontmostApplication, app.bundleIdentifier == id {
            app.hide()
        } else {
            workspace.launchApplication(
                withBundleIdentifier: id,
                options: [],
                additionalEventParamDescriptor: nil,
                launchIdentifier: nil
            )
        }
    }
}
