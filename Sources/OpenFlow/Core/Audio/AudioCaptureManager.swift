import AVFoundation
import Accelerate
import Combine

@MainActor
class AudioCaptureManager: NSObject, ObservableObject {
    static let shared: AudioCaptureManager = MainActor.assumeIsolated {
        AudioCaptureManager()
    }
    
    private let audioEngine = AVAudioEngine()
    private var inputNode: AVAudioInputNode?
    
    @Published var isRecording = false
    @Published var audioLevel: Float = 0.0
    
    var audioDataHandler: (([Float]) -> Void)?
    
    private let sampleRate: Double = 16000.0
    private var audioBuffer: [Float] = []
    
    private override init() {
        super.init()
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        inputNode = audioEngine.inputNode
    }
    
    func startRecording() throws {
        guard !isRecording else { return }
        
        let inputNode = audioEngine.inputNode
        let inputFormat = inputNode.outputFormat(forBus: 0)
        
        let format = AVAudioFormat(
            commonFormat: .pcmFormatFloat32,
            sampleRate: sampleRate,
            channels: 1,
            interleaved: false
        )
        
        guard let recordingFormat = format else {
            throw AudioCaptureError.formatError
        }
        
        guard let converter = AVAudioConverter(from: inputFormat, to: recordingFormat) else {
            throw AudioCaptureError.converterError
        }
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: inputFormat) { [weak self] buffer, time in
            guard let self = self else { return }
            
            let convertedBuffer = self.convertBuffer(buffer, using: converter, to: recordingFormat)
            let samples = Array(UnsafeBufferPointer(start: convertedBuffer.floatChannelData?[0], count: Int(convertedBuffer.frameLength)))
            
            self.audioBuffer.append(contentsOf: samples)
            
            let level = self.calculateAudioLevel(samples: samples)
            Task { @MainActor in
                self.audioLevel = level
            }
            
            self.audioDataHandler?(samples)
        }
        
        try audioEngine.start()
        isRecording = true
    }
    
    func stopRecording() {
        guard isRecording else { return }
        
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        
        isRecording = false
        audioLevel = 0.0
    }
    
    private func convertBuffer(_ buffer: AVAudioPCMBuffer, using converter: AVAudioConverter, to format: AVAudioFormat) -> AVAudioPCMBuffer {
        let outputBuffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(format.sampleRate * Double(buffer.frameLength) / buffer.format.sampleRate))!
        
        var error: NSError?
        converter.convert(to: outputBuffer, error: &error) { inNumPackets, outStatus in
            outStatus.pointee = .haveData
            return buffer
        }
        
        return outputBuffer
    }
    
    private func calculateAudioLevel(samples: [Float]) -> Float {
        guard !samples.isEmpty else { return 0.0 }
        
        var mean: Float = 0
        vDSP_measqv(samples, 1, &mean, vDSP_Length(samples.count))
        
        let db = 10 * log10(mean)
        let normalizedLevel = max(0, min(1, (db + 60) / 60))
        
        return normalizedLevel
    }
    
    func getRecordedAudio() -> [Float] {
        let audio = audioBuffer
        audioBuffer.removeAll()
        return audio
    }
    
    func clearBuffer() {
        audioBuffer.removeAll()
    }
}

enum AudioCaptureError: Error {
    case formatError
    case converterError
    case permissionDenied
}
