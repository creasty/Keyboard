import Cocoa

extension AXUIElement {
    func getAttribute<T>(_ attribute: AXAttribute<T>) throws -> T? {
        return try getAttribute(attribute.key)
    }

    func getAttribute<T>(_ attribute: String) throws -> T? {
        var value: AnyObject?
        let error = AXUIElementCopyAttributeValue(self, attribute as CFString, &value)

        if error == .noValue || error == .attributeUnsupported {
            return nil
        }
        guard error == .success else {
            throw error
        }

        return unpackAXValue(value!) as? T
    }

    func setAttribute<T>(_ attribute: AXAttribute<T>, value: T) throws {
        try setAttribute(attribute.key, value: value)
    }

    func setAttribute(_ attribute: String, value: Any) throws {
        let error = AXUIElementSetAttributeValue(self, attribute as CFString, packAXValue(value))

        guard error == .success else {
            throw error
        }
    }

    private func unpackAXValue(_ value: AnyObject) -> Any {
        switch CFGetTypeID(value) {
        case AXUIElementGetTypeID():
            return value
        case AXValueGetTypeID():
            let type = AXValueGetType(value as! AXValue)
            switch type {
            case .axError:
                var result: AXError = .success
                let success = AXValueGetValue(value as! AXValue, type, &result)
                assert(success)
                return result
            case .cfRange:
                var result: CFRange = CFRange()
                let success = AXValueGetValue(value as! AXValue, type, &result)
                assert(success)
                return result
            case .cgPoint:
                var result: CGPoint = CGPoint.zero
                let success = AXValueGetValue(value as! AXValue, type, &result)
                assert(success)
                return result
            case .cgRect:
                var result: CGRect = CGRect.zero
                let success = AXValueGetValue(value as! AXValue, type, &result)
                assert(success)
                return result
            case .cgSize:
                var result: CGSize = CGSize.zero
                let success = AXValueGetValue(value as! AXValue, type, &result)
                assert(success)
                return result
            case .illegal:
                return value
            }
        default:
            return value
        }
    }

    private func packAXValue(_ value: Any) -> AnyObject {
        switch value {
        case var val as CFRange:
            return AXValueCreate(AXValueType(rawValue: kAXValueCFRangeType)!, &val)!
        case var val as CGPoint:
            return AXValueCreate(AXValueType(rawValue: kAXValueCGPointType)!, &val)!
        case var val as CGRect:
            return AXValueCreate(AXValueType(rawValue: kAXValueCGRectType)!, &val)!
        case var val as CGSize:
            return AXValueCreate(AXValueType(rawValue: kAXValueCGSizeType)!, &val)!
        default:
            return value as AnyObject
        }
    }
}

extension NSRunningApplication {
    func axUIElement() -> AXUIElement? {
        if isTerminated {
            return nil
        }
        if processIdentifier < 0 {
            return nil
        }
        return AXUIElementCreateApplication(processIdentifier)
    }
}
