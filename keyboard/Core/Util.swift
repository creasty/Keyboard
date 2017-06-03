import Cocoa

let terminalApplications: Set<String> = [
    "com.apple.Terminal",
    "iTerm",
    "net.sourceforge.iTerm",
    "com.googlecode.iterm2",
    "co.zeit.hyperterm",
    "co.zeit.hyper",
]

let emacsApplications: Set<String> = [
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

extension NSEventModifierFlags {
    func match(
        shift: Bool? = false,
        control: Bool? = false,
        option: Bool? = false,
        command: Bool? = false
    ) -> Bool {
        if let shift = shift, contains(.shift) != shift {
            return false
        }
        if let control = control, contains(.control) != control {
            return false
        }
        if let option = option, contains(.option) != option {
            return false
        }
        if let command = command, contains(.command) != command {
            return false
        }
        return true
    }
}

extension DispatchTime {
    static func uptimeNanoseconds() -> Double {
        return Double(now().uptimeNanoseconds)
    }
}
