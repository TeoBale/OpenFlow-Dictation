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
    }
    
    private func setupAudioHandler() {
        audioManager.audioDataHandler = { [weak self] samples in
            self?.transcriptionSession.appendAudio(samples)
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
        
        guard PermissionManager.shared.requestAccessibilityPermission() else {
            showAccessibilityAlert()
            return
        }
        
        do {
            try audioManager.startRecording()
            transcriptionSession.start()
            
            isRecording = true
            isTranscribing = true
            currentTranscription = ""
            
            print("Dictation started")
        } catch {
            print("Failed to start recording: \(error)")
        }
    }
    
    func stop() {
        guard isRecording else { return }
        
        audioManager.stopRecording()
        
        let finalText = transcriptionSession.stop()
        isRecording = false
        isTranscribing = false
        
        let processedText = ideIntegration.processForIDE(text: finalText)
        
        KeyboardSimulator.insertText(processedText)
        
        currentTranscription = ""
        
        print("Dictation stopped. Inserted: \(processedText)")
    }
    
    private func showAccessibilityAlert() {
        let alert = NSAlert()
        alert.messageText = "Accessibility Permission Required"
        alert.informativeText = "OpenFlow needs accessibility access to type text into applications. Please grant permission in System Settings > Privacy & Security > Accessibility."
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
}
