import SwiftUI
import Combine

@MainActor
class StatusBarController: ObservableObject {
    static let shared: StatusBarController = MainActor.assumeIsolated {
        StatusBarController()
    }
    
    private var statusItem: NSStatusItem
    private var menu: NSMenu
    private var languageMenu: NSMenu?
    
    @Published var isRecording = false
    
    // Available languages
    let languages = [
        ("en", "English"),
        ("es", "Spanish"),
        ("fr", "French"),
        ("de", "German"),
        ("it", "Italian"),
        ("pt", "Portuguese"),
        ("nl", "Dutch"),
        ("ja", "Japanese"),
        ("zh", "Chinese"),
        ("ru", "Russian")
    ]
    
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
        
        // Language submenu
        let currentLanguage = getCurrentLanguage()
        let languageItem = NSMenuItem(
            title: "Language: \(languageName(for: currentLanguage))",
            action: nil,
            keyEquivalent: ""
        )
        languageMenu = createLanguageMenu()
        languageItem.submenu = languageMenu
        menu.addItem(languageItem)
        
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
    
    private func createLanguageMenu() -> NSMenu {
        let submenu = NSMenu()
        let currentLang = getCurrentLanguage()
        
        for (code, name) in languages {
            let item = NSMenuItem(
                title: name,
                action: #selector(selectLanguage(_:)),
                keyEquivalent: ""
            )
            item.target = self
            item.representedObject = code
            item.state = (code == currentLang) ? .on : .off
            submenu.addItem(item)
        }
        
        return submenu
    }
    
    private func getCurrentLanguage() -> String {
        return UserDefaults.standard.string(forKey: "dictationLanguage") ?? "en"
    }
    
    private func languageName(for code: String) -> String {
        return languages.first { $0.0 == code }?.1 ?? code
    }
    
    @objc private func selectLanguage(_ sender: NSMenuItem) {
        guard let languageCode = sender.representedObject as? String else { return }
        
        UserDefaults.standard.set(languageCode, forKey: "dictationLanguage")
        print("🌍 Language changed to: \(languageName(for: languageCode))")
        
        // Update menu to reflect the change
        updateMenu()
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
