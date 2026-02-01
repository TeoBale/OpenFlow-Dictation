import SwiftUI

struct SettingsView: View {
    @State private var selectedLanguage = "en"
    @State private var selectedModel = "base.en"
    @State private var showOverlay = true
    @State private var autoPunctuation = true
    @State private var removeFillers = true
    
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
    
    let models = [
        "tiny.en",
        "tiny",
        "base.en",
        "base",
        "small.en",
        "small"
    ]
    
    var body: some View {
        TabView {
            generalTab
                .tabItem {
                    Label("General", systemImage: "gear")
                }
            
            textProcessingTab
                .tabItem {
                    Label("Text", systemImage: "textformat")
                }
            
            modelsTab
                .tabItem {
                    Label("Models", systemImage: "cpu")
                }
            
            shortcutsTab
                .tabItem {
                    Label("Shortcuts", systemImage: "keyboard")
                }
        }
        .frame(width: 500, height: 400)
        .padding()
    }
    
    var generalTab: some View {
        Form {
            Section(header: Text("Language")) {
                Picker("Recognition Language", selection: $selectedLanguage) {
                    ForEach(languages, id: \.0) { code, name in
                        Text(name).tag(code)
                    }
                }
                .pickerStyle(DefaultPickerStyle())
            }
            
            Section(header: Text("Display")) {
                Toggle("Show dictation overlay", isOn: $showOverlay)
            }
            
            Section {
                HStack {
                    Spacer()
                    Button("Reset to Defaults") {
                        resetToDefaults()
                    }
                    Spacer()
                }
            }
        }
    }
    
    var textProcessingTab: some View {
        Form {
            Section(header: Text("Auto-Correction")) {
                Toggle("Auto-punctuation", isOn: $autoPunctuation)
                Toggle("Remove filler words (um, uh, like)", isOn: $removeFillers)
            }
            
            Section(header: Text("Custom Dictionary")) {
                HStack {
                    Text("Manage custom words and phrases")
                    Spacer()
                    Button("Open Editor...") {
                        openDictionaryEditor()
                    }
                }
            }
        }
    }
    
    var modelsTab: some View {
        Form {
            Section(header: Text("Model Selection")) {
                Picker("Whisper Model", selection: $selectedModel) {
                    ForEach(models, id: \.self) { model in
                        Text(model).tag(model)
                    }
                }
                
                Text("Larger models are more accurate but slower and use more memory.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Section {
                HStack {
                    Spacer()
                    Button("Download Models...") {
                        downloadModels()
                    }
                    Spacer()
                }
            }
        }
    }
    
    var shortcutsTab: some View {
        Form {
            Section(header: Text("Global Shortcuts")) {
                HStack {
                    Text("Toggle Dictation")
                    Spacer()
                    Text("⌘⇧Space")
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(4)
                }
            }
            
            Section(header: Text("Dictation Controls")) {
                Text("Press the hotkey to toggle dictation on/off")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private func resetToDefaults() {
        selectedLanguage = "en"
        selectedModel = "base.en"
        showOverlay = true
        autoPunctuation = true
        removeFillers = true
    }
    
    private func openDictionaryEditor() {
        // To be implemented
    }
    
    private func downloadModels() {
        if let url = URL(string: "https://github.com/ggerganov/whisper.cpp/tree/master/models") {
            NSWorkspace.shared.open(url)
        }
    }
}
