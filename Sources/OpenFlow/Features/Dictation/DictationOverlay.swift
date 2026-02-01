import SwiftUI

struct DictationOverlay: View {
    @ObservedObject var dictationService = DictationService.shared
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                AudioWaveform(level: dictationService.isRecording ? 0.7 : 0.0)
                    .frame(width: 40, height: 30)
                
                Text(dictationService.isRecording ? "Listening..." : "Ready")
                    .font(.headline)
                    .foregroundColor(dictationService.isRecording ? .red : .secondary)
                
                Spacer()
                
                Button(action: {
                    DictationService.shared.toggle()
                }) {
                    Image(systemName: dictationService.isRecording ? "stop.fill" : "mic.fill")
                        .font(.title2)
                        .foregroundColor(dictationService.isRecording ? .red : .blue)
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            if !dictationService.currentTranscription.isEmpty {
                Divider()
                
                ScrollView {
                    Text(dictationService.currentTranscription)
                        .font(.body)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 4)
                }
                .frame(maxHeight: 100)
            }
        }
        .padding()
        .frame(width: 350)
        .background(
            VisualEffectView(material: .hudWindow, blendingMode: .behindWindow)
        )
        .cornerRadius(12)
        .shadow(radius: 10)
    }
}

struct AudioWaveform: View {
    let level: Float
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 2) {
                ForEach(0..<5) { index in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.red)
                        .frame(width: 4)
                        .frame(height: geometry.size.height * CGFloat(randomHeight(for: index)))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .animation(.easeInOut(duration: 0.1).repeatForever(autoreverses: true), value: level)
        }
    }
    
    private func randomHeight(for index: Int) -> Float {
        let baseHeight: Float = 0.3
        let variance: Float = level > 0 ? 0.7 : 0
        let phase = Float(index) * 0.5
        return baseHeight + variance * abs(sin(phase + Float(Date().timeIntervalSince1970) * 5))
    }
}

struct VisualEffectView: NSViewRepresentable {
    var material: NSVisualEffectView.Material
    var blendingMode: NSVisualEffectView.BlendingMode
    
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        return view
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}
