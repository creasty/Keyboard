import Cocoa

extension NSScreen {
    static var currentScreen: NSScreen? {
        let mouseLocation = NSEvent.mouseLocation
        return NSScreen.screens.first(where: { NSMouseInRect(mouseLocation, $0.frame, false) })
    }

    static var currentScreenRect: CGRect? {
        guard let mainScreen = NSScreen.main else { return nil }
        guard let currentScreen = currentScreen else { return nil }

        // Convert the coordinate system
        var rect = currentScreen.frame
        rect.origin.y = (mainScreen.frame.origin.y + mainScreen.frame.size.height) - (currentScreen.frame.origin.y + currentScreen.frame.size.height)

        return rect
    }
}
