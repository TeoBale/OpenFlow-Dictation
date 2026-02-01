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
    
    private func loadDefaultModel() {
        let modelPath = getDefaultModelPath()
        
        if FileManager.default.fileExists(atPath: modelPath) {
            let _ = WhisperEngine.shared.loadModel(from: modelPath)
        } else {
            print("Default model not found at: \(modelPath)")
            print("Please download a Whisper model to: ~/Library/Application Support/OpenFlow/Models/")
        }
    }
    
    private func getDefaultModelPath() -> String {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let modelDir = appSupport.appendingPathComponent("OpenFlow/Models")
        return modelDir.appendingPathComponent("ggml-base.en.bin").path
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
        
        do {
            // Clear any previous audio
            audioManager.clearBuffer()
            
            try audioManager.startRecording()
            transcriptionSession.start()
            
            isRecording = true
            isTranscribing = true
            currentTranscription = ""
            
            print("Dictation started - speak now...")
            print("Press Cmd+Shift+Space again to stop")
        } catch {
            print("Failed to start recording: \(error)")
            isRecording = false
            showErrorAlert(message: "Failed to start recording. Please check microphone permissions.")
        }
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
        
        // Process audio with Whisper (placeholder for now)
        var finalText = ""
        if !audioData.isEmpty {
            // TODO: Real transcription
            finalText = WhisperEngine.shared.transcribe(audioData: audioData)?.text ?? ""
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
