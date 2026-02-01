import Foundation
import Combine

@MainActor
class TranscriptionSession: ObservableObject {
    @Published var currentTranscription: String = ""
    @Published var isTranscribing: Bool = false
    
    private var audioBuffer: [Float] = []
    private let processingInterval: TimeInterval = 1.0
    private var processingTimer: Timer?
    
    private let engine = WhisperEngine.shared
    private var textProcessor = TextFormatter()
    
    func start(language: String = "en") {
        isTranscribing = true
        audioBuffer.removeAll()
        currentTranscription = ""
        
        processingTimer = Timer.scheduledTimer(withTimeInterval: processingInterval, repeats: true) { [weak self] _ in
            self?.processBuffer(language: language)
        }
    }
    
    func stop() -> String {
        isTranscribing = false
        processingTimer?.invalidate()
        processingTimer = nil
        
        let finalTranscription = processBuffer(language: "en", final: true)
        audioBuffer.removeAll()
        
        return finalTranscription
    }
    
    func appendAudio(_ samples: [Float]) {
        audioBuffer.append(contentsOf: samples)
    }
    
    @discardableResult
    private func processBuffer(language: String, final: Bool = false) -> String {
        guard !audioBuffer.isEmpty else { return currentTranscription }
        
        let samplesToProcess = audioBuffer
        if !final {
            audioBuffer.removeAll()
        }
        
        guard let result = engine.transcribe(audioData: samplesToProcess, language: language) else {
            return currentTranscription
        }
        
        let processedText = textProcessor.process(result.text)
        
        if final {
            currentTranscription = processedText
        } else {
            currentTranscription = textProcessor.process(result.text, partial: true)
        }
        
        return currentTranscription
    }
}
