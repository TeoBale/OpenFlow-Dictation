import Foundation
import CWhisper

// Non-isolated since whisper runs its own threads
final class WhisperEngine: @unchecked Sendable {
    nonisolated static let shared = WhisperEngine()
    
    private var ctx: OpaquePointer?
    private var isModelLoaded = false
    private var modelPath: String?
    private let lock = NSLock()
    
    private init() {}
    
    func loadModel(from path: String) -> Bool {
        lock.lock()
        defer { lock.unlock() }
        
        guard !isModelLoaded else { return true }
        
        print("Loading Whisper model from: \(path)")
        
        // Check if file exists
        guard FileManager.default.fileExists(atPath: path) else {
            print("Model file not found: \(path)")
            return false
        }
        
        // Initialize whisper context
        var params = whisper_context_default_params()
        params.use_gpu = true  // Enable Metal GPU acceleration
        
        ctx = whisper_init_from_file_with_params(path, params)
        
        guard ctx != nil else {
            print("Failed to initialize Whisper context")
            return false
        }
        
        modelPath = path
        isModelLoaded = true
        print("Whisper model loaded successfully")
        return true
    }
    
    func transcribe(audioData: [Float], language: String = "en") -> TranscriptionResult? {
        lock.lock()
        defer { lock.unlock() }
        
        guard let ctx = ctx, isModelLoaded else {
            print("Whisper model not loaded")
            return nil
        }
        
        guard !audioData.isEmpty else {
            return nil
        }
        
        // Create full params for transcription
        var wparams = whisper_full_default_params(WHISPER_SAMPLING_GREEDY)
        wparams.print_realtime = false
        wparams.print_progress = false
        wparams.print_timestamps = false
        wparams.print_special = false
        wparams.translate = false
        wparams.no_context = true
        wparams.single_segment = true
        wparams.max_tokens = 0
        wparams.language = (language as NSString).utf8String
        wparams.n_threads = Int32(ProcessInfo.processInfo.processorCount)
        wparams.offset_ms = 0
        wparams.duration_ms = 0
        
        // Run transcription
        let result = whisper_full(ctx, wparams, audioData, Int32(audioData.count))
        
        guard result == 0 else {
            print("Whisper transcription failed with error code: \(result)")
            return nil
        }
        
        // Extract text from segments
        let nSegments = whisper_full_n_segments(ctx)
        var text = ""
        
        for i in 0..<nSegments {
            if let segmentText = whisper_full_get_segment_text(ctx, i) {
                text += String(cString: segmentText)
            }
        }
        
        text = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !text.isEmpty else {
            return nil
        }
        
        return TranscriptionResult(
            text: text,
            confidence: 1.0,
            startTime: 0,
            endTime: Double(audioData.count) / 16000.0
        )
    }
    
    func unloadModel() {
        lock.lock()
        defer { lock.unlock() }
        
        if let ctx = ctx {
            whisper_free(ctx)
            self.ctx = nil
        }
        isModelLoaded = false
        modelPath = nil
    }
}
