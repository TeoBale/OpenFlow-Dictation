import AVFoundation
import Accelerate
import Combine
import Dispatch

// Non-isolated class because audio callbacks run on real-time threads
final class AudioCaptureManager: NSObject, ObservableObject, @unchecked Sendable {
    static let shared = AudioCaptureManager()
    
    private let audioEngine = AVAudioEngine()
    private var inputNode: AVAudioInputNode?
    private var isTapInstalled = false
    private let audioQueue = DispatchQueue(label: "com.openflow.audio", qos: .userInitiated)
    
    @Published var isRecording = false
    @Published var audioLevel: Float = 0.0
    
    // Handler for audio data - called on audio queue
    var audioDataHandler: (([Float]) -> Void)?
    // Handler for level updates - called on main queue
    var levelUpdateHandler: ((Float) -> Void)?
    
    private let sampleRate: Double = 16000.0
    private var audioBuffer: [Float] = []
    private let bufferLock = NSLock()
    
    private override init() {
        super.init()
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        inputNode = audioEngine.inputNode
    }
    
    func startRecording() throws {
        guard !isRecording else { 
            print("Already recording")
            return 
        }
        
        // Reset engine state
        if audioEngine.isRunning {
            audioEngine.stop()
        }
        
        // Remove existing tap if any
        if isTapInstalled {
            audioEngine.inputNode.removeTap(onBus: 0)
            isTapInstalled = false
        }
        
        let inputNode = audioEngine.inputNode
        let inputFormat = inputNode.outputFormat(forBus: 0)
        
        // Check if input format is valid
        guard inputFormat.sampleRate > 0 else {
            throw AudioCaptureError.formatError
        }
        
        // Install tap - callback runs on real-time audio thread
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: inputFormat) { [weak self] buffer, time in
            guard let self = self else { return }
            
            // Only process if we're recording
            guard self.isRecording else { return }
            
            autoreleasepool {
                guard let channelData = buffer.floatChannelData else { return }
                
                let frameLength = Int(buffer.frameLength)
                let inputSamples = Array(UnsafeBufferPointer(start: channelData[0], count: frameLength))
                
                // Convert to 16kHz mono
                if let convertedSamples = self.resampleAudio(inputSamples, from: inputFormat.sampleRate, to: self.sampleRate) {
                    // Lock to safely append to buffer
                    self.bufferLock.lock()
                    self.audioBuffer.append(contentsOf: convertedSamples)
                    self.bufferLock.unlock()
                    
                    // Calculate level and notify on main queue
                    let level = self.calculateAudioLevel(samples: convertedSamples)
                    DispatchQueue.main.async { [weak self] in
                        self?.audioLevel = level
                        self?.levelUpdateHandler?(level)
                    }
                    
                    // Call data handler on audio queue
                    self.audioDataHandler?(convertedSamples)
                }
            }
        }
        
        isTapInstalled = true
        
        do {
            try audioEngine.start()
            
            // Update state on main queue
            DispatchQueue.main.async { [weak self] in
                self?.isRecording = true
            }
            
            print("Audio recording started")
        } catch {
            inputNode.removeTap(onBus: 0)
            isTapInstalled = false
            throw error
        }
    }
    
    func stopRecording() {
        guard isRecording else { return }
        
        // Update state first
        DispatchQueue.main.async { [weak self] in
            self?.isRecording = false
            self?.audioLevel = 0.0
        }
        
        // Stop engine
        audioEngine.stop()
        
        // Remove tap after a short delay to let pending callbacks finish
        audioQueue.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self = self, self.isTapInstalled else { return }
            self.audioEngine.inputNode.removeTap(onBus: 0)
            self.isTapInstalled = false
            print("Audio recording stopped")
        }
    }
    
    private func resampleAudio(_ samples: [Float], from sourceRate: Double, to targetRate: Double) -> [Float]? {
        guard sourceRate > 0 && targetRate > 0 else { return nil }
        
        let ratio = targetRate / sourceRate
        let outputLength = Int(Double(samples.count) * ratio)
        
        guard outputLength > 0 else { return nil }
        
        var outputSamples = [Float](repeating: 0, count: outputLength)
        
        // Simple linear interpolation for resampling
        for i in 0..<outputLength {
            let position = Double(i) / ratio
            let index = Int(position)
            let fraction = position - Double(index)
            
            if index < samples.count - 1 {
                outputSamples[i] = samples[index] * Float(1 - fraction) + samples[index + 1] * Float(fraction)
            } else if index < samples.count {
                outputSamples[i] = samples[index]
            }
        }
        
        return outputSamples
    }
    
    private func calculateAudioLevel(samples: [Float]) -> Float {
        guard !samples.isEmpty else { return 0.0 }
        
        var mean: Float = 0
        vDSP_measqv(samples, 1, &mean, vDSP_Length(samples.count))
        
        let db = 10 * log10(max(mean, 1e-10))
        let normalizedLevel = max(0, min(1, (db + 60) / 60))
        
        return normalizedLevel
    }
    
    func getRecordedAudio() -> [Float] {
        bufferLock.lock()
        let audio = audioBuffer
        audioBuffer.removeAll()
        bufferLock.unlock()
        return audio
    }
    
    func getCurrentBuffer() -> [Float] {
        bufferLock.lock()
        let audio = Array(audioBuffer)
        bufferLock.unlock()
        return audio
    }
    
    func clearBuffer() {
        bufferLock.lock()
        audioBuffer.removeAll()
        bufferLock.unlock()
    }
}

enum AudioCaptureError: Error {
    case formatError
    case converterError
    case permissionDenied
}
