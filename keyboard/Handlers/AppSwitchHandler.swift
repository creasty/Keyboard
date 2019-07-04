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
    let workspace: NSWorkspace
    private let emitter: EmitterType

    init(workspace: NSWorkspace, emitter: EmitterType) {
        self.workspace = workspace
        self.emitter = emitter
    }

    func activateSuperKeys() -> [KeyCode] {
        return [.semicolon]
    }

    func handle(keyEvent: KeyEvent) -> HandlerAction? {
        return nil
    }

    func handleSuperKey(prefix: KeyCode, keys: Set<KeyCode>) -> Bool {
        guard prefix == .semicolon else { return false }

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
        case [.b]:
            showOrHideApplication("net.shinyfrog.bear")
            return true
        case [.n]:
            showOrHideApplication("notion.id")
            return true
        default:
            return false
        }
    }
}
