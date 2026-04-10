import ApplicationServices
import CoreGraphics
import Foundation

struct AXAttributeReader {
    func value<T>(for attribute: CFString, on element: AXUIElement, as type: T.Type = T.self) -> T? {
        var rawValue: CFTypeRef?
        let error = AXUIElementCopyAttributeValue(element, attribute, &rawValue)
        guard error == .success else { return nil }
        return rawValue as? T
    }

    func bool(for attribute: CFString, on element: AXUIElement) -> Bool? {
        value(for: attribute, on: element, as: NSNumber.self)?.boolValue
    }

    func cgPoint(for attribute: CFString, on element: AXUIElement) -> CGPoint? {
        guard let rawValue: AXValue = value(for: attribute, on: element, as: AXValue.self) else {
            return nil
        }
        var point = CGPoint.zero
        return AXValueGetValue(rawValue, .cgPoint, &point) ? point : nil
    }

    func cgSize(for attribute: CFString, on element: AXUIElement) -> CGSize? {
        guard let rawValue: AXValue = value(for: attribute, on: element, as: AXValue.self) else {
            return nil
        }
        var size = CGSize.zero
        return AXValueGetValue(rawValue, .cgSize, &size) ? size : nil
    }

    func cgRect(for attribute: CFString, on element: AXUIElement) -> CGRect? {
        guard let rawValue: AXValue = value(for: attribute, on: element, as: AXValue.self) else {
            return nil
        }
        var rect = CGRect.zero
        return AXValueGetValue(rawValue, .cgRect, &rect) ? rect : nil
    }
}
