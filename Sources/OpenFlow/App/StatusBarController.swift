import SwiftUI
import Combine

@MainActor
class StatusBarController: ObservableObject {
    static let shared: StatusBarController = MainActor.assumeIsolated {
        StatusBarController()
    }
    
    private var statusItem: NSStatusItem
    private var menu: NSMenu
    
    @Published var isRecording = false
    
    init() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        menu = NSMenu()
        
        setupMenuBar()
    }
    
    private func setupMenuBar() {
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "waveform", accessibilityDescription: "OpenFlow Dictation")
        }
        
        updateMenu()
    }
    
    private func updateMenu() {
        menu.removeAllItems()
        
        let startItem = NSMenuItem(
            title: isRecording ? "Stop Dictation" : "Start Dictation",
            action: #selector(toggleDictation),
            keyEquivalent: ""
        )
        startItem.target = self
        menu.addItem(startItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // Shortcuts info
        let shortcutsHeader = NSMenuItem(
            title: "Shortcuts:",
            action: nil,
            keyEquivalent: ""
        )
        shortcutsHeader.isEnabled = false
        menu.addItem(shortcutsHeader)
        
        let primaryShortcut = NSMenuItem(
            title: "  • Press your dictation key",
            action: nil,
            keyEquivalent: ""
        )
        primaryShortcut.isEnabled = false
        menu.addItem(primaryShortcut)
        
        let stopShortcut = NSMenuItem(
            title: "  • Press Esc to stop",
            action: nil,
            keyEquivalent: ""
        )
        stopShortcut.isEnabled = false
        menu.addItem(stopShortcut)
        
        menu.addItem(NSMenuItem.separator())
        
        let settingsItem = NSMenuItem(
            title: "Settings...",
            action: #selector(openSettings),
            keyEquivalent: ","
        )
        settingsItem.target = self
        menu.addItem(settingsItem)
        
        menu.addItem(NSMenuItem.separator())
        
        let quitItem = NSMenuItem(
            title: "Quit OpenFlow",
            action: #selector(quitApp),
            keyEquivalent: "q"
        )
        quitItem.target = self
        menu.addItem(quitItem)
        
        statusItem.menu = menu
    }
    
    @objc private func toggleDictation() {
        DictationService.shared.toggle()
        isRecording = DictationService.shared.isRecording
        updateMenu()
    }
    
    @objc private func openSettings() {
        NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    @objc private func quitApp() {
        NSApp.terminate(nil)
    }
}
