import Foundation
import ApplicationServices

struct AccessibilityHelpers {
    static func getFocusedElement() -> AXUIElement? {
        let systemWide = AXUIElementCreateSystemWide()
        
        var focusedElement: AnyObject?
        let result = AXUIElementCopyAttributeValue(
            systemWide,
            kAXFocusedUIElementAttribute as CFString,
            &focusedElement
        )
        
        guard result == .success else {
            return nil
        }
        
        return (focusedElement as! AXUIElement)
    }
    
    static func getFocusedElementValue() -> String? {
        guard let element = getFocusedElement() else {
            return nil
        }
        
        var value: AnyObject?
        let result = AXUIElementCopyAttributeValue(
            element,
            kAXValueAttribute as CFString,
            &value
        )
        
        guard result == .success else {
            return nil
        }
        
        return value as? String
    }
    
    static func setFocusedElementValue(_ text: String) -> Bool {
        guard let element = getFocusedElement() else {
            return false
        }
        
        let result = AXUIElementSetAttributeValue(
            element,
            kAXValueAttribute as CFString,
            text as CFTypeRef
        )
        
        return result == .success
    }
}
