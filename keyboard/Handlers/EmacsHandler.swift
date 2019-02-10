import Cocoa

private let terminalApplications: Set<String> = [
    "com.apple.Terminal",
    "net.sourceforge.iTerm",
    "com.googlecode.iterm2",
    "co.zeit.hyperterm",
    "co.zeit.hyper",
    "io.alacritty",
]

private let emacsApplications: Set<String> = [
    // eclipse
    "org.eclipse.eclipse",
    "org.eclipse.platform.ide",
    "org.eclipse.sdk.ide",
    "com.springsource.sts",
    "org.springsource.sts.ide",

    // emacs
    "org.gnu.Emacs",
    "org.gnu.AquamacsEmacs",
    "org.gnu.Aquamacs",
    "org.pqrs.unknownapp.conkeror",

    // remote desktop connection
    "com.microsoft.rdc",
    "com.microsoft.rdc.mac",
    "com.microsoft.rdc.osx.beta",
    "net.sf.cord",
    "com.thinomenon.RemoteDesktopConnection",
    "com.itap-mobile.qmote",
    "com.nulana.remotixmac",
    "com.p5sys.jump.mac.viewer",
    "com.p5sys.jump.mac.viewer.web",
    "com.vmware.horizon",
    "com.2X.Client.Mac",
    "karabiner.remotedesktop.microsoft",
    "karabiner.remotedesktop",

    // TERMINAL
    "com.apple.Terminal",
    "iTerm",
    "net.sourceforge.iTerm",
    "com.googlecode.iterm2",
    "co.zeit.hyperterm",
    "co.zeit.hyper",
    "io.alacritty",

    // vi
    "org.vim.MacVim",

    // virtualmachine
    "com.vmware.fusion",
    "com.vmware.horizon",
    "com.vmware.view",
    "com.parallels.desktop",
    "com.parallels.vm",
    "com.parallels.desktop.console",
    "org.virtualbox.app.VirtualBoxVM",

    // x11
    "org.x.X11",
    "com.apple.x11",
    "org.macosforge.xquartz.X11",
    "org.macports.X11",
]

// Emacs mode:
//
//     Ctrl-C    Escape
//     Ctrl-D    Forward delete
//     Ctrl-H    Backspace
//     Ctrl-J    Enter
//     Ctrl-P    ↑
//     Ctrl-N    ↓
//     Ctrl-B    ←
//     Ctrl-F    →
//     Ctrl-A    Beginning of line (Shift allowed)
//     Ctrl-E    End of line (Shift allowed)
//
final class EmacsHandler: Handler {
    private let workspace: NSWorkspace
    private let emitter: EmitterType

    init(workspace: NSWorkspace, emitter: EmitterType) {
        self.workspace = workspace
        self.emitter = emitter
    }

    func handle(keyEvent: KeyEvent) -> HandlerAction? {
        guard let bundleId = workspace.frontmostApplication?.bundleIdentifier else {
            return nil
        }

        if !terminalApplications.contains(bundleId) {
            if keyEvent.match(code: .c, control: true) {
                if keyEvent.isDown {
                    emitter.emit(code: .jisEisu)
                }
                emitter.emit(code: .escape, action: (keyEvent.isDown ? .down : .up))
                return .prevent
            }
        }

        if !emacsApplications.contains(bundleId) {
            var remap: (KeyCode, CGEventFlags)? = nil

            if keyEvent.match(control: true) {
                switch keyEvent.code {
                case .d:
                    remap = (.forwardDelete, [])
                case .h:
                    remap = (.backspace, [])
                case .j:
                    remap = (.enter, [])
                default:
                    break
                }
            }
            if keyEvent.match(shift: nil, control: true) {
                switch keyEvent.code {
                case .p:
                    remap = (.upArrow, [])
                case .n:
                    remap = (.downArrow, [])
                case .b:
                    remap = (.leftArrow, [])
                case .f:
                    remap = (.rightArrow, [])
                case .a:
                    remap = (.leftArrow, [.maskCommand])
                case .e:
                    remap = (.rightArrow, [.maskCommand])
                default:
                    break
                }
            }

            if let remap = remap {
                let remapFlags = keyEvent.shift
                    ? remap.1.union(.maskShift)
                    : remap.1

                emitter.emit(code: remap.0, flags: remapFlags, action: (keyEvent.isDown ? .down : .up))
                return .prevent
            }
        }

        return nil
    }

    func handleSuperKey(prefix: KeyCode, keys: Set<KeyCode>) -> Bool {
        return false
    }
}
