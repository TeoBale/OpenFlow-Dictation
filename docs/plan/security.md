# Security & Permissions

---

## Required Permissions

### macOS Info.plist entries

```xml
<key>NSMicrophoneUsageDescription</key>
<string>OpenFlow Dictation needs microphone access to transcribe your speech.</string>

<key>NSSpeechRecognitionUsageDescription</key>
<string>OpenFlow Dictation uses speech recognition locally on your device.</string>

<key>NSAccessibilityUsageDescription</key>
<string>OpenFlow Dictation needs accessibility access to insert text into applications and integrate with IDEs.</string>
```

### User Actions Required

1. Grant Microphone access (system dialog on first use)
2. Grant Accessibility access (System Settings → Privacy & Security → Accessibility)
3. (Optional) Add to Login Items for startup

---

## Security Considerations

- **No network calls**: App does not make any HTTP requests
- **No data collection**: No analytics, no crash reporting (unless user opts in)
- **Sandboxing**: Not sandboxed (required for Accessibility APIs and IDE integration)
- **Code signing**: Unsigned distribution (Homebrew builds from source, GitHub releases require manual Gatekeeper bypass)
- **Transparency**: Full source code available for audit - build yourself to verify no malicious code

---

[← Back to Overview](./README.md)
