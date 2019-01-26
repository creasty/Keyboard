import Cocoa

// Swtich between apps:
//
//     ;+F   Finder
//     ;+M   Terminal
//     ;+T   Things
//     ;+B   Bear
//
final class AppSwitchHandler: Handler {
    private let workspace: NSWorkspace
    private let emitter: EmitterType

    init(workspace: NSWorkspace, emitter: EmitterType) {
        self.workspace = workspace
        self.emitter = emitter
    }

    func handle(keyEvent: KeyEvent) -> HandlerAction? {
        return nil
    }

    func handleSuperKey(prefix: KeyCode, keys: Set<KeyCode>) -> Bool {
        guard prefix == .semicolon else {
            return false
        }

        switch keys {
        case [.f]:
            showOrHideApplication(byBundleIdentifier: "com.apple.finder")
            return true
        case [.m]:
            showOrHideApplication(byBundleIdentifier: "com.googlecode.iterm2")
            return true
        case [.t]:
            showOrHideApplication(byBundleIdentifier: "com.culturedcode.ThingsMac")
            return true
        case [.b]:
            showOrHideApplication(byBundleIdentifier: "net.shinyfrog.bear")
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
