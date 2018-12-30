import Cocoa

private let terminalApplications: Set<String> = [
    "com.apple.Terminal",
    "iTerm",
    "net.sourceforge.iTerm",
    "com.googlecode.iterm2",
    "co.zeit.hyperterm",
    "co.zeit.hyper",
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
final class EmacsEventHandler: EventHandler {
    private let workspace = NSWorkspace.shared
    private let emitter = Emitter()

    func handle(key: KeyCode, flags: NSEvent.ModifierFlags, isKeyDown: Bool, isARepeat: Bool) -> EventHandlerAction? {
        guard let bundleId = workspace.frontmostApplication?.bundleIdentifier else {
            return nil
        }

        if !terminalApplications.contains(bundleId) {
            if key == .c && flags.match(control: true) {
                if isKeyDown {
                    emitter.emit(key: .jisEisu)
                }
                emitter.emit(key: .escape, action: (isKeyDown ? .down : .up))
                return .prevent
            }
        }

        if !emacsApplications.contains(bundleId) {
            var remap: (KeyCode, CGEventFlags)? = nil

            if flags.match(control: true) {
                switch key {
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
            if flags.match(shift: nil, control: true) {
                switch key {
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
                let remapFlags = flags.contains(.shift)
                    ? remap.1.union(.maskShift)
                    : remap.1

                emitter.emit(key: remap.0, flags: remapFlags, action: (isKeyDown ? .down : .up))
                return .prevent
            }
        }

        return nil
    }
}
