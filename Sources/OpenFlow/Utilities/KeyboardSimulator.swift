import Foundation
import CoreGraphics
import Carbon
import ApplicationServices

class KeyboardSimulator {
    static func insertText(_ text: String) {
        if insertViaAppleEvents(text) {
            return
        }
        
        insertViaKeystrokes(text)
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
        
        let setResult = AXUIElementSetAttributeValue(
            axElement,
            kAXValueAttribute as CFString,
            text as CFTypeRef
        )
        
        return setResult == .success
    }
    
    private static func insertViaKeystrokes(_ text: String) {
        for char in text {
            let keyCode = keyCodeForCharacter(char)
            
            if keyCode > 0 {
                simulateKeyPress(keyCode: keyCode, useShift: char.isUppercase)
            } else {
                simulateUnicodeInput(char)
            }
        }
    }
    
    private static func simulateKeyPress(keyCode: Int, useShift: Bool) {
        let keyDownEvent = CGEvent(keyboardEventSource: nil, virtualKey: CGKeyCode(keyCode), keyDown: true)
        let keyUpEvent = CGEvent(keyboardEventSource: nil, virtualKey: CGKeyCode(keyCode), keyDown: false)
        
        if useShift {
            keyDownEvent?.flags = .maskShift
            keyUpEvent?.flags = .maskShift
        }
        
        keyDownEvent?.post(tap: .cghidEventTap)
        keyUpEvent?.post(tap: .cghidEventTap)
        
        usleep(1000)
    }
    
    private static func simulateUnicodeInput(_ char: Character) {
        if let scalars = String(char).unicodeScalars.first {
            let source = CGEventSource(stateID: .combinedSessionState)
            let event = CGEvent(keyboardEventSource: source, virtualKey: 0, keyDown: true)
            let unicodeValue = UniChar(scalars.value)
            event?.keyboardSetUnicodeString(stringLength: 1, unicodeString: [unicodeValue])
            event?.post(tap: .cghidEventTap)
            
            let upEvent = CGEvent(keyboardEventSource: source, virtualKey: 0, keyDown: false)
            upEvent?.post(tap: .cghidEventTap)
        }
    }
    
    private static func keyCodeForCharacter(_ char: Character) -> Int {
        let keyMap: [Character: Int] = [
            "a": 0, "s": 1, "d": 2, "f": 3, "h": 4, "g": 5, "z": 6, "x": 7,
            "c": 8, "v": 9, "b": 11, "q": 12, "w": 13, "e": 14, "r": 15,
            "y": 16, "t": 17, "1": 18, "2": 19, "3": 20, "4": 21, "6": 22,
            "5": 23, "=": 24, "9": 25, "7": 26, "-": 27, "8": 28, "0": 29,
            "]": 30, "o": 31, "u": 32, "[": 33, "i": 34, "p": 35, "l": 37,
            "j": 38, "'": 39, "k": 40, ";": 41, "\\": 42, ",": 43, "/": 44,
            "n": 45, "m": 46, ".": 47, " ": 49
        ]
        
        return keyMap[char.lowercased().first ?? " "] ?? -1
    }
}
