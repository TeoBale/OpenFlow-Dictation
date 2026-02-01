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
    private var isMonitoring = false
    
    // Primary shortcut: Custom key (code 179)
    private let primaryKeyCode: Int64 = 179
    
    // Emergency stop: Escape key
    private let escapeKeyCode: Int64 = 53
    
    private init() {}
    
    func registerHotkeys() {
        print("⌨️  Registering hotkeys...")
        
        guard PermissionManager.shared.requestAccessibilityPermission() else {
            print("❌ Accessibility permission required")
            showAccessibilityPermissionAlert()
            return
        }
        
        setupEventTap()
    }
    
    private func setupEventTap() {
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
            print("❌ Failed to create event tap")
            return
        }
        
        eventTap = tap
        runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
        
        guard let source = runLoopSource else { return }
        
        CFRunLoopAddSource(CFRunLoopGetCurrent(), source, .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)
        isMonitoring = true
        
        print("✅ Hotkeys active: Press your dictation key to toggle, Esc to stop")
    }
    
    private func showAccessibilityPermissionAlert() {
        let alert = NSAlert()
        alert.messageText = "Accessibility Permission Required"
        alert.informativeText = "OpenFlow needs accessibility access for global hotkeys.\n\nEnable it in:\nSystem Settings > Privacy & Security > Accessibility"
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Open Settings")
        alert.addButton(withTitle: "Cancel")
        
        if alert.runModal() == .alertFirstButtonReturn {
            if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
                NSWorkspace.shared.open(url)
            }
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
        isMonitoring = false
    }
    
    private static func handleEvent(proxy: CGEventTapProxy, type: CGEventType, event: CGEvent, refcon: UnsafeMutableRawPointer?) -> Unmanaged<CGEvent>? {
        
        let keyCode = event.getIntegerValueField(.keyboardEventKeycode)
        
        guard let shared = Unmanaged<HotkeyManager>.fromOpaque(refcon!).takeUnretainedValue() as HotkeyManager? else {
            return Unmanaged.passRetained(event)
        }
        
        // Primary: Custom key (179) - toggle dictation
        if keyCode == shared.primaryKeyCode {
            Task { @MainActor in
                DictationService.shared.toggle()
            }
            return nil // Consume event
        }
        
        // Emergency: Escape - stop dictation if active
        if keyCode == shared.escapeKeyCode && DictationService.shared.isRecording {
            Task { @MainActor in
                DictationService.shared.stop()
            }
            return nil // Consume event
        }
        
        return Unmanaged.passRetained(event)
    }
}
