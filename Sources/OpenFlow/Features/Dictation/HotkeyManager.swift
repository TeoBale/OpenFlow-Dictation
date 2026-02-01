import Foundation
import Carbon
import AppKit

@MainActor
class HotkeyManager {
    static let shared: HotkeyManager = MainActor.assumeIsolated {
        HotkeyManager()
    }
    
    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    
    private init() {}
    
    func registerHotkeys() {
        let eventMask = CGEventMask(1 << CGEventType.keyDown.rawValue)
        
        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: eventMask,
            callback: { proxy, type, event, refcon in
                return HotkeyManager.handleEvent(proxy: proxy, type: type, event: event, refcon: refcon)
            },
            userInfo: UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        ) else {
            print("Failed to create event tap")
            return
        }
        
        eventTap = tap
        runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
        
        if let source = runLoopSource {
            CFRunLoopAddSource(CFRunLoopGetCurrent(), source, .commonModes)
            CGEvent.tapEnable(tap: tap, enable: true)
        }
    }
    
    func unregisterHotkeys() {
        if let tap = eventTap {
            CGEvent.tapEnable(tap: tap, enable: false)
        }
        
        if let source = runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetCurrent(), source, .commonModes)
        }
        
        if let tap = eventTap {
            CFMachPortInvalidate(tap)
        }
        
        eventTap = nil
        runLoopSource = nil
    }
    
    private static func handleEvent(proxy: CGEventTapProxy, type: CGEventType, event: CGEvent, refcon: UnsafeMutableRawPointer?) -> Unmanaged<CGEvent>? {
        guard type == .keyDown else {
            return Unmanaged.passRetained(event)
        }
        
        let keyCode = event.getIntegerValueField(.keyboardEventKeycode)
        let flags = event.flags
        
        // Check for Cmd+Shift+Space (keycode 49 is space)
        if keyCode == 49 && flags.contains(.maskCommand) && flags.contains(.maskShift) {
            Task { @MainActor in
                DictationService.shared.toggle()
            }
            // Consume the event
            return nil
        }
        
        return Unmanaged.passRetained(event)
    }
}
