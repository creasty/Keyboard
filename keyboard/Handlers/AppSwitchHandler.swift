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

    private lazy var superKeyHandler: SuperKeyHandler = {
        return SuperKeyHandler(key: .semicolon, emitter: emitter) { [weak self] (key) in
            self?.execute(key: key)
        }
    }()

    init(workspace: NSWorkspace, emitter: EmitterType) {
        self.workspace = workspace
        self.emitter = emitter
    }

    func handle(key: KeyCode, flags: NSEvent.ModifierFlags, isKeyDown: Bool, isARepeat: Bool) -> HandlerAction? {
        return superKeyHandler.handle(key: key, flags: flags, isKeyDown: isKeyDown, isARepeat: isARepeat)
    }

    private func execute(key: KeyCode) {
        switch key {
        case .f:
            showOrHideApplication(byBundleIdentifier: "com.apple.finder")
        case .m:
            showOrHideApplication(byBundleIdentifier: "com.googlecode.iterm2")
        case .t:
            showOrHideApplication(byBundleIdentifier: "com.culturedcode.ThingsMac")
        case .b:
            showOrHideApplication(byBundleIdentifier: "net.shinyfrog.bear")
        default:
            break
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
