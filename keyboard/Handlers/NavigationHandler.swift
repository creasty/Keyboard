import Cocoa

private let witchBundleId = "com.manytricks.WitchWrapper"

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
final class NavigationHandler: Handler, ApplicationLaunchable {
    let workspace: NSWorkspace
    private let emitter: EmitterType
    private lazy var hasWitch: Bool = {
        return workspace.absolutePathForApplication(withBundleIdentifier: witchBundleId) != nil
    }()

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
            if hasWitch {
                emitter.emit(code: .tab, flags: [.maskAlternate])
            } else {
                emitter.emit(code: .tab, flags: [.maskCommand])
            }
            return true
        case [.k]:
            if hasWitch {
                emitter.emit(code: .tab, flags: [.maskAlternate, .maskShift])
            } else {
                emitter.emit(code: .tab, flags: [.maskCommand, .maskShift])
            }
            return true
        case [.l]:
            emitter.emit(code: .rightArrow, flags: [.maskControl, .maskSecondaryFn])
            return true
        case [.n]:
            if hasWitch {
                emitter.emit(code: .tab, flags: [.maskControl, .maskAlternate])
            } else {
                emitter.emit(code: .f1, flags: [.maskCommand])
            }
            return true
        case [.b]:
            if hasWitch {
                emitter.emit(code: .tab, flags: [.maskControl, .maskAlternate, .maskShift])
            } else {
                emitter.emit(code: .f1, flags: [.maskCommand, .maskShift])
            }
            return true
        case [.m]:
            showOrHideApplication("com.apple.exposelauncher")
            return true
        default:
            return false
        }
    }
}
