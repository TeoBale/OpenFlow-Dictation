import Foundation

struct TranscriptionResult {
    let text: String
    let confidence: Float
    let startTime: TimeInterval
    let endTime: TimeInterval
    
    init(text: String, confidence: Float = 1.0, startTime: TimeInterval = 0, endTime: TimeInterval = 0) {
        self.text = text
        self.confidence = confidence
        self.startTime = startTime
        self.endTime = endTime
    }
}
