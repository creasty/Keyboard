import Cocoa

// Swtich between apps:
//
//     ;+F   Finder
//     ;+M   Terminal
//     ;+T   Things
//     ;+B   Bear
//
final class AppSwitchHandler: SuperKeyHandler {
    private let workspace: NSWorkspace
    private let emitter: EmitterType

    init(workspace: NSWorkspace, emitter: EmitterType) {
        self.workspace = workspace
        self.emitter = emitter
        super.init(key: .semicolon, emitter: emitter)
    }

    override func execute(key: KeyCode) {
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
