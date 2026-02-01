import SwiftUI

@main
struct OpenFlowApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            SettingsView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusBarController: StatusBarController?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        
        PermissionManager.shared.requestMicrophonePermission { granted in
            if granted {
                print("Microphone permission granted")
            } else {
                print("Microphone permission denied")
            }
        }
        
        statusBarController = StatusBarController()
        
        HotkeyManager.shared.registerHotkeys()
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        HotkeyManager.shared.unregisterHotkeys()
    }
}
