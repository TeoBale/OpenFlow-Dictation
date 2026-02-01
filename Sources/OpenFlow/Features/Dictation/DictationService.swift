import Foundation
import Combine
import AppKit

@MainActor
class DictationService: ObservableObject {
    static let shared: DictationService = MainActor.assumeIsolated {
        DictationService()
    }
    
    @Published var isRecording = false
    @Published var currentTranscription = ""
    @Published var isTranscribing = false
    
    private let audioManager = AudioCaptureManager.shared
    private let transcriptionSession = TranscriptionSession()
    private let ideIntegration = IDEIntegrationService.shared
    
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        setupAudioHandler()
        loadDefaultModel()
        
        // Subscribe to audio manager changes
        audioManager.$isRecording
            .receive(on: DispatchQueue.main)
            .sink { [weak self] recording in
                self?.isRecording = recording
            }
            .store(in: &cancellables)
        
        audioManager.$audioLevel
            .receive(on: DispatchQueue.main)
            .sink { [weak self] level in
                // Can use this for UI updates
            }
            .store(in: &cancellables)
    }
    
    private func setupAudioHandler() {
        // Audio handler runs on audio queue, not main queue
        audioManager.audioDataHandler = { [weak self] samples in
            // Just accumulate audio, don't do transcription here
            // Transcription will happen when stop is called
        }
    }
    
    private var currentModelPath: String = ""
    
    private func loadDefaultModel() {
        if let modelPath = findAvailableModel() {
            currentModelPath = modelPath
            let _ = WhisperEngine.shared.loadModel(from: modelPath)
            print("📦 Loaded model: \(URL(fileURLWithPath: modelPath).lastPathComponent)")
        } else {
            print("❌ No Whisper model found")
            print("📥 Please download a model:")
            print("   ./Scripts/download_models.sh ggml-base.bin    (multilingual)")
            print("   ./Scripts/download_models.sh ggml-base.en.bin (English only)")
        }
    }
    
    private func findAvailableModel() -> String? {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let modelDir = appSupport.appendingPathComponent("OpenFlow/Models")
        
        // Priority order: multilingual models first, then English-only
        let preferredModels = [
            "ggml-base.bin",      // Multilingual base model
            "ggml-small.bin",     // Multilingual small model
            "ggml-tiny.bin",      // Multilingual tiny model
            "ggml-base.en.bin",   // English-only base model
            "ggml-small.en.bin",  // English-only small model
            "ggml-tiny.en.bin"    // English-only tiny model
        ]
        
        for modelName in preferredModels {
            let modelPath = modelDir.appendingPathComponent(modelName).path
            if FileManager.default.fileExists(atPath: modelPath) {
                return modelPath
            }
        }
        
        return nil
    }
    
    private func getDefaultModelPath() -> String {
        return currentModelPath
    }
    
    func toggle() {
        if isRecording {
            stop()
        } else {
            start()
        }
    }
    
    func start() {
        guard !isRecording else { return }
        
        // Check accessibility - required for text injection
        guard PermissionManager.shared.requestAccessibilityPermission() else {
            showAccessibilityAlert()
            return
        }
        
        // Check language/model compatibility
        checkLanguageCompatibility()
        
        do {
            // Clear any previous audio
            audioManager.clearBuffer()
            
            try audioManager.startRecording()
            transcriptionSession.start()
            
            isRecording = true
            isTranscribing = true
            currentTranscription = ""
            
            print("Dictation started - speak now...")
            print("Press your dictation key again to stop")
        } catch {
            print("Failed to start recording: \(error)")
            isRecording = false
            showErrorAlert(message: "Failed to start recording. Please check microphone permissions.")
        }
    }
    
    private func checkLanguageCompatibility() {
        let language = UserDefaults.standard.string(forKey: "dictationLanguage") ?? "en"
        let modelPath = currentModelPath
        
        // Only check if we have a model loaded
        guard !modelPath.isEmpty else { return }
        
        // Check if using English-only model with non-English language
        let modelName = URL(fileURLWithPath: modelPath).lastPathComponent
        if modelName.contains(".en.") && language != "en" {
            print("⚠️  WARNING: Using English-only model '\(modelName)' for \(language) language")
            print("⚠️  For better \(language) support, download: ggml-base.bin")
            print("⚠️  Run: ./Scripts/download_models.sh ggml-base.bin")
            
            // Show warning to user (only once per session)
            showLanguageWarning(language: language)
        }
    }
    
    private var hasShownLanguageWarning = false
    
    private func showLanguageWarning(language: String) {
        guard !hasShownLanguageWarning else { return }
        hasShownLanguageWarning = true
        
        let languageNames = [
            "es": "Spanish", "fr": "French", "de": "German", 
            "it": "Italian", "pt": "Portuguese", "nl": "Dutch",
            "ja": "Japanese", "zh": "Chinese", "ru": "Russian"
        ]
        let langName = languageNames[language] ?? language
        
        let alert = NSAlert()
        alert.messageText = "Language Support Limited"
        alert.informativeText = "You're trying to dictate in \(langName), but you have the English-only model installed.\n\nTo support \(langName) and other languages, download the multilingual model:\n\n./Scripts/download_models.sh ggml-base.bin"
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
    
    func stop() {
        guard isRecording else { return }
        
        print("Stopping dictation...")
        
        // Stop audio first
        audioManager.stopRecording()
        
        // Get all recorded audio
        let audioData = audioManager.getRecordedAudio()
        
        // Stop transcription session
        transcriptionSession.stop()
        
        isRecording = false
        isTranscribing = false
        
        // Process audio with Whisper
        var finalText = ""
        if !audioData.isEmpty {
            // Get selected language
            let language = UserDefaults.standard.string(forKey: "dictationLanguage") ?? "en"
            print("🌍 Transcribing in language: \(language)")
            
            finalText = WhisperEngine.shared.transcribe(audioData: audioData, language: language)?.text ?? ""
        }
        
        if finalText.isEmpty {
            finalText = "[No speech detected]"
        }
        
        // Process for IDE integration
        let processedText = ideIntegration.processForIDE(text: finalText)
        
        print("Transcribed: \(processedText)")
        
        // Insert text
        if processedText != "[No speech detected]" {
            KeyboardSimulator.insertText(processedText)
        }
        
        currentTranscription = ""
    }
    
    private func showAccessibilityAlert() {
        let alert = NSAlert()
        alert.messageText = "Accessibility Permission Required"
        alert.informativeText = "OpenFlow needs accessibility access to type text into applications. Please:\n\n1. Open System Settings > Privacy & Security > Accessibility\n2. Add and enable OpenFlow\n3. Restart the app"
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Open System Settings")
        alert.addButton(withTitle: "Cancel")
        
        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
                NSWorkspace.shared.open(url)
            }
        }
    }
    
    private func showErrorAlert(message: String) {
        let alert = NSAlert()
        alert.messageText = "Error"
        alert.informativeText = message
        alert.alertStyle = .critical
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
}
