import Cocoa
import InputMethodKit

extension TISInputSource {
    private func getProperty(_ key: CFString) -> AnyObject? {
        guard let cfType = TISGetInputSourceProperty(self, key) else { return nil }
        return Unmanaged<AnyObject>.fromOpaque(cfType).takeUnretainedValue()
    }

    var id: String {
        return getProperty(kTISPropertyInputSourceID) as! String
    }

    var category: String {
        return getProperty(kTISPropertyInputSourceCategory) as! String
    }

    var isKeyboardInputSource: Bool {
        return category == (kTISCategoryKeyboardInputSource as String)
    }

    var isSelectable: Bool {
        return getProperty(kTISPropertyInputSourceIsSelectCapable) as! Bool
    }

    var isSelected: Bool {
        return getProperty(kTISPropertyInputSourceIsSelected) as! Bool
    }

    var sourceLanguages: [String] {
        return getProperty(kTISPropertyInputSourceLanguages) as! [String]
    }

    var isCJKV: Bool {
        if let lang = sourceLanguages.first {
            return ["ko", "ja", "vi"].contains(lang) || lang.hasPrefix("zh")
        }
        return false
    }
}
