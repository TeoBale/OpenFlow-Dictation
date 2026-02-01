# Technical Specifications

Detailed technical implementation details for all features.

---

## 1. Core Dictation

### Audio Pipeline

```
Microphone → AVAudioEngine → Ring Buffer → VAD (optional) → Whisper.cpp → Text
```

**Specifications:**
- Sample rate: 16kHz (Whisper requirement)
- Format: Mono, Float32
- Buffer size: 1024-4096 samples
- Processing: Real-time streaming with 500ms chunks

**Voice Activity Detection (Optional):**
- Energy-based thresholding
- Configurable sensitivity
- Auto-stop after silence (3-5 seconds)

### Text Injection

**Methods (in order of preference):**
1. **Apple Events (AXUIElement)**: Direct text field insertion
2. **Keystroke Simulation**: Character-by-character typing
3. **Clipboard**: Copy-paste fallback

**Fallback Strategy:**
- Try Apple Events first (most apps)
- Fall back to keystrokes if Events fail
- Use clipboard for non-input fields (with notification)

---

## 2. Rule-Based Text Processing

### Filler Word Removal

**Words to remove:**
- "um", "uh", "ah", "er"
- "like" (when used as filler)
- "you know", "I mean", "sort of"
- "basically", "literally" (when filler)

**Implementation:**
- Regex-based matching
- Context-aware (preserve "like" in "I like this")
- Configurable word list

### Auto-Punctuation

**Rules:**
- Pause > 0.8s → period (if sentence-like)
- Rising intonation + pause → question mark
- "comma", "period", "question mark" spoken literally
- List items ("first", "second", "next") → commas between

**Implementation:**
- Timing analysis from audio stream
- Simple keyword matching for explicit punctuation
- Basic POS tagging for sentence detection

### Backtrack Handling

**Patterns:**
- "Actually, [correction]" → replace previous word/phrase
- "I mean [correction]" → replace
- "Make that [correction]" → replace previous number/word
- "Scratch that" → delete last sentence

**Implementation:**
- Keep last 10 seconds of transcription buffer
- Pattern matching on transcript
- Rollback and reinsert

---

## 3. IDE Integration

### Cursor/Windsurf Integration

**File Tagging:**
- Trigger: "tag [filename]" or "@[filename]"
- Action: Simulates @ keypress, types filename
- Implementation: Apple Accessibility API to detect IDE, then keyboard simulation

**Command Injection:**
- "run this" → Adds "Run this code" to prompt
- "explain this" → Adds "Explain this code" to prompt
- "refactor this" → Adds "Refactor this" to prompt
- Implementation: Detect IDE context, prepend command to transcript

**IDE Detection:**
```swift
// Check active application
let frontmostApp = NSWorkspace.shared.frontmostApplication
if frontmostApp.bundleIdentifier == "com.cursor.app" {
    // Enable Cursor-specific features
}
```

### VS Code Integration

**Phase 1**: Basic text injection (same as any app)
**Phase 2**: Companion extension for better integration

---

## 4. Custom Dictionary

**Features:**
- Add custom words/phrases
- Pronunciation hints (phonetic spelling)
- Industry-specific terminology
- Proper nouns (names, companies)
- Acronyms and abbreviations

**Storage:**
- JSON file in Application Support directory
- Manual editing via Settings UI
- Auto-add from corrections (future feature)

---

## Technical Implementation Details

### Whisper Integration

**Model Loading:**
```swift
class WhisperEngine {
    private var ctx: OpaquePointer?  // whisper.cpp context
    
    func loadModel(_ modelPath: String) {
        // Load model file
        let params = whisper_context_default_params()
        ctx = whisper_init_from_file_with_params(modelPath, params)
    }
    
    func transcribe(audioData: [Float]) -> String {
        // Process audio buffer
        // Return transcription
    }
}
```

**Optimization:**
- Use Metal GPU backend (`-DWHISPER_METAL=ON`)
- Quantized models (Q5_0) for faster inference
- Persistent context (don't reload model between sessions)

### Audio Capture

```swift
class AudioCaptureManager {
    private let audioEngine = AVAudioEngine()
    
    func startRecording() {
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, time in
            // Process buffer
            self.processAudioBuffer(buffer)
        }
        
        try? audioEngine.start()
    }
}
```

### Global Hotkeys

```swift
import KeyboardShortcuts

extension KeyboardShortcuts.Name {
    static let toggleDictation = Self("toggleDictation")
}

// Register in app startup
KeyboardShortcuts.onKeyUp(for: .toggleDictation) {
    DictationService.shared.toggle()
}
```

### Text Injection

```swift
class KeyboardSimulator {
    static func insertText(_ text: String) {
        // Try Apple Events first
        if let systemWide = AXUIElementCreateSystemWide() {
            // Get focused element
            var focusedElement: AnyObject?
            AXUIElementCopyAttributeValue(systemWide, kAXFocusedUIElementAttribute as CFString, &focusedElement)
            
            // Try to set value
            if let element = focusedElement {
                AXUIElementSetAttributeValue(element as! AXUIElement, kAXValueAttribute as CFString, text as CFTypeRef)
            }
        }
        
        // Fallback to CGEvent keyboard simulation
        // ... keystroke injection code
    }
}
```

---

[← Back to Overview](./README.md)
