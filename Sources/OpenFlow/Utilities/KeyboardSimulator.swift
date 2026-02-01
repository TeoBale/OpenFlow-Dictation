import Foundation
import CoreGraphics
import Carbon
import ApplicationServices

@MainActor
class KeyboardSimulator {
    static func insertText(_ text: String) {
        // Try Apple Events first (most reliable)
        if insertViaAppleEvents(text) {
            return
        }
        
        // Fallback to Unicode keystroke simulation for all characters
        // This avoids keyboard layout issues
        insertViaUnicodeKeystrokes(text)
    }
    
    private static func insertViaAppleEvents(_ text: String) -> Bool {
        let systemWide = AXUIElementCreateSystemWide()
        
        var focusedElement: AnyObject?
        let result = AXUIElementCopyAttributeValue(
            systemWide,
            kAXFocusedUIElementAttribute as CFString,
            &focusedElement
        )
        
        guard result == .success, let element = focusedElement else {
            return false
        }
        
        let axElement = element as! AXUIElement
        
        // For text fields, try to append to existing text
        var currentValue: AnyObject?
        AXUIElementCopyAttributeValue(axElement, kAXValueAttribute as CFString, &currentValue)
        
        let newValue: String
        if let existing = currentValue as? String {
            newValue = existing + text
        } else {
            newValue = text
        }
        
        let setResult = AXUIElementSetAttributeValue(
            axElement,
            kAXValueAttribute as CFString,
            newValue as CFTypeRef
        )
        
        return setResult == .success
    }
    
    private static func insertViaUnicodeKeystrokes(_ text: String) {
        // Use CGEvent keyboardSetUnicodeString for proper Unicode support
        // This handles all characters correctly regardless of keyboard layout
        
        for char in text {
            autoreleasepool {
                guard let scalar = char.unicodeScalars.first else { return }
                
                // Convert to UniChar (UInt16)
                let unicodeValue = UniChar(scalar.value)
                
                // Create key down event with Unicode string
                if let source = CGEventSource(stateID: .combinedSessionState) {
                    let keyDown = CGEvent(keyboardEventSource: source, virtualKey: 0, keyDown: true)
                    keyDown?.keyboardSetUnicodeString(stringLength: 1, unicodeString: [unicodeValue])
                    keyDown?.post(tap: .cghidEventTap)
                    
                    // Small delay for stability
                    usleep(1000)
                    
                    // Key up
                    let keyUp = CGEvent(keyboardEventSource: source, virtualKey: 0, keyDown: false)
                    keyUp?.post(tap: .cghidEventTap)
                    
                    usleep(1000)
                }
            }
        }
    }
}
