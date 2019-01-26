import Cocoa

enum KeyCode: UInt16 {
    case a              = 0x00
    case s              = 0x01
    case d              = 0x02
    case f              = 0x03
    case h              = 0x04
    case g              = 0x05
    case z              = 0x06
    case x              = 0x07
    case c              = 0x08
    case v              = 0x09
    case b              = 0x0b
    case q              = 0x0c
    case w              = 0x0d
    case e              = 0x0e
    case r              = 0x0f
    case y              = 0x10
    case t              = 0x11
    case i1             = 0x12 // exclamation "!"
    case i2             = 0x13 // atmark "@"
    case i3             = 0x14 // hash "#"
    case i4             = 0x15 // dollar "$"
    case i5             = 0x17 // percent "%"
    case i6             = 0x16 // hat "^"
    case equal          = 0x18 // plus "+"
    case i9             = 0x19 // leftParen "("
    case i7             = 0x1a // ampersand "&"
    case minus          = 0x1b
    case i8             = 0x1c // asterisk "*"
    case i0             = 0x1d // rightParen ")"
    case rightBracket   = 0x1e // "]" / rightBrace "}"
    case o              = 0x1f
    case u              = 0x20
    case leftBracket    = 0x21 // "[" / leftBrace "{"
    case i              = 0x22
    case p              = 0x23
    case l              = 0x25
    case j              = 0x26
    case doubleQuote    = 0x27 // """ / singleQuote "'"
    case k              = 0x28
    case semicolon      = 0x29 // ";" / colon ":"
    case backslash      = 0x2a // "\" / pipe "|"
    case comma          = 0x2b // "," / leftAngledBracket "<"
    case slash          = 0x2c // "/" / question "?"
    case n              = 0x2d
    case m              = 0x2e
    case period         = 0x2f // "." / rightAngledBracket ">"
    case backtick       = 0x32 // "`" / tilde "~"
    case keypadDecimal  = 0x41
    case keypadMultiply = 0x43
    case keypadPlus     = 0x45
    case keypadClear    = 0x47
    case keypadDivide   = 0x4b
    case keypadEnter    = 0x4c
    case keypadMinus    = 0x4e
    case keypadEquals   = 0x51
    case keypad0        = 0x52
    case keypad1        = 0x53
    case keypad2        = 0x54
    case keypad3        = 0x55
    case keypad4        = 0x56
    case keypad5        = 0x57
    case keypad6        = 0x58
    case keypad7        = 0x59
    case keypad8        = 0x5b
    case keypad9        = 0x5c
    case backspace      = 0x33
    case enter          = 0x24

    // Independent of keyboard layout
    case tab           = 0x30
    case space         = 0x31
    case escape        = 0x35
    case command       = 0x37
    case shift         = 0x38
    case capsLock      = 0x39
    case option        = 0x3a
    case control       = 0x3b
    case rightShift    = 0x3c
    case rightOption   = 0x3d
    case rightControl  = 0x3e
    case function      = 0x3f
    case f17           = 0x40
    case volumeUp      = 0x48
    case volumeDown    = 0x49
    case mute          = 0x4a
    case f18           = 0x4f
    case f19           = 0x50
    case f20           = 0x5a
    case f5            = 0x60
    case f6            = 0x61
    case f7            = 0x62
    case f3            = 0x63
    case f8            = 0x64
    case f9            = 0x65
    case f11           = 0x67
    case f13           = 0x69
    case f16           = 0x6a
    case f14           = 0x6b
    case f10           = 0x6d
    case f12           = 0x6f
    case f15           = 0x71
    case help          = 0x72
    case home          = 0x73
    case pageUp        = 0x74
    case forwardDelete = 0x75
    case f4            = 0x76
    case end           = 0x77
    case f2            = 0x78
    case pageDown      = 0x79
    case f1            = 0x7a
    case leftArrow     = 0x7b
    case rightArrow    = 0x7c
    case downArrow     = 0x7d
    case upArrow       = 0x7e

    // ISO keyboard
    case isoSection =  0x0a

    // JIS keyboard
    case jisYen =          0x5d
//    case jisXXX =          0x5e
    case jisKeypadComma =  0x5f
    case jisEisu =         0x66
    case jisKana =         0x68
}

struct KeyEvent {
    let code: KeyCode
    let shift: Bool
    let control: Bool
    let option: Bool
    let command: Bool

    let flags: NSEvent.ModifierFlags

    let isDown: Bool
    let isARepeat: Bool

    init?(nsEvent: NSEvent) {
        guard let code = KeyCode(rawValue: nsEvent.keyCode) else {
            return nil
        }

        self.code = code
        flags = nsEvent.modifierFlags
        shift = nsEvent.modifierFlags.contains(.shift)
        control = nsEvent.modifierFlags.contains(.control)
        option = nsEvent.modifierFlags.contains(.option)
        command = nsEvent.modifierFlags.contains(.command)

        isDown = (nsEvent.type == .keyDown)
        isARepeat = nsEvent.isARepeat
    }

    func match(
        code: KeyCode? = nil,
        shift: Bool? = false,
        control: Bool? = false,
        option: Bool? = false,
        command: Bool? = false
    ) -> Bool {
        if let code = code, self.code != code {
            return false
        }
        if let shift = shift, self.shift != shift {
            return false
        }
        if let control = control, self.control != control {
            return false
        }
        if let option = option, self.option != option {
            return false
        }
        if let command = command, self.command != command {
            return false
        }
        return true
    }
}
