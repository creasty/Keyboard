import Cocoa

protocol ApplicationLaunchable {
    var workspace: NSWorkspace { get }

    func showOrHideApplication(_ id: String)
}

extension ApplicationLaunchable {
    func showOrHideApplication(_ id: String) {
        if let app = workspace.runningApplications.first(where: { $0.bundleIdentifier == id }) {
            if app.isActive {
                app.hide()
            } else {
                app.unhide()
                app.activate(options: [.activateIgnoringOtherApps])
            }
            return
        }

        workspace.launchApplication(
            withBundleIdentifier: id,
            options: [],
            additionalEventParamDescriptor: nil,
            launchIdentifier: nil
        )
    }
}

// Swtich between apps:
//
//     ;+F   Finder
//     ;+M   Terminal
//     ;+T   Things
//     ;+B   Bear
//
final class AppSwitchHandler: Handler, ApplicationLaunchable {
    struct Const {
        static let superKey: KeyCode = .semicolon
    }

    let workspace: NSWorkspace

    init(workspace: NSWorkspace) {
        self.workspace = workspace
    }

    func activateSuperKeys() -> [KeyCode] {
        return [Const.superKey]
    }

    func handle(keyEvent: KeyEvent) -> HandlerAction? {
        return nil
    }

    func handleSuperKey(prefix: KeyCode, keys: Set<KeyCode>) -> Bool {
        guard prefix == Const.superKey else { return false }

        switch keys {
        case [.f]:
            showOrHideApplication("com.apple.finder")
            return true
        case [.m]:
            showOrHideApplication("io.alacritty")
            return true
        case [.t]:
            showOrHideApplication("com.culturedcode.ThingsMac")
            return true
        case [.n]:
            showOrHideApplication("net.shinyfrog.bear")
            return true
        default:
            return false
        }
    }
}
