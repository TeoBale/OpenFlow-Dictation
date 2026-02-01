# Architecture & Technology Stack

---

## Technology Stack

### Core Framework

**Core Framework:**
- **Language**: Swift 5.9+
- **UI Framework**: SwiftUI
- **Audio Capture**: AVAudioEngine (low-level, minimal latency)
- **Speech Recognition**: whisper.cpp (C++ bindings)
- **System Integration**: Apple Accessibility APIs
- **Build System**: Xcode 15+, Swift Package Manager

**Dependencies:**
```
- whisper.cpp (MIT) - Local speech recognition
- KeyboardShortcuts (MIT) - Global hotkey management
- swift-argument-parser (Apache-2.0) - CLI interface
```

**Whisper Models:**
- **Tiny** (~39MB) - Emergency fallback, very fast, lower accuracy
- **Base** (~74MB) - Default, good balance, <300ms latency on M-series
- **Small** (~244MB) - High accuracy, <800ms latency, optional download

---

[← Back to Overview](./README.md)
