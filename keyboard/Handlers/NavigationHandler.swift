import Cocoa

private let witch3BundleId = "com.manytricks.WitchWrapper"
private let witch4PrefPanePath = "Library/PreferencePanes/Witch.prefPane"

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
    struct Const {
        static let superKey: KeyCode = .s
    }

    let workspace: NSWorkspace
    private let fileManager: FileManager
    private let emitter: EmitterType

    private var homeDirectory: URL {
        if #available(OSX 10.12, *) {
            return fileManager.homeDirectoryForCurrentUser
        } else {
            return URL(fileURLWithPath: NSHomeDirectory())
        }
    }

    private lazy var hasWitch3: Bool = {
        return workspace.absolutePathForApplication(withBundleIdentifier: witch3BundleId) != nil
    }()
    private lazy var hasWitch4: Bool = {
        let prefPath = homeDirectory.appendingPathComponent(witch4PrefPanePath, isDirectory: false).path
        return fileManager.fileExists(atPath: prefPath)
    }()
    private lazy var hasWitch: Bool = {
        return hasWitch4 || hasWitch3
    }()

    init(workspace: NSWorkspace, fileManager: FileManager, emitter: EmitterType) {
        self.workspace = workspace
        self.fileManager = fileManager
        self.emitter = emitter
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
        case [.b], [.p]:
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
