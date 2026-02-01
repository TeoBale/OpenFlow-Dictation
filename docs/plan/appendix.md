# Appendix

---

## A. Model Performance Benchmarks

| Model | Size | WER (English) | Latency (M1) | RAM Usage |
|-------|------|---------------|--------------|-----------|
| Tiny | 39MB | ~18% | ~100ms | ~50MB |
| Base | 74MB | ~12% | ~300ms | ~100MB |
| Small | 244MB | ~8% | ~800ms | ~300MB |
| Medium | 769MB | ~6% | ~2s | ~800MB |

*Benchmarks measured on M1 MacBook Air*

---

## B. Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| ⌘ + Shift + Space | Toggle dictation |
| ⌘ + Shift + . | Stop dictation (emergency) |
| ⌘ + Shift + , | Open settings |

*All shortcuts configurable in Settings*

---

## C. File Formats

**Configuration**: `~/Library/Application Support/OpenFlow/config.json`
**Dictionary**: `~/Library/Application Support/OpenFlow/dictionary.json`
**Models**: `~/Library/Application Support/OpenFlow/models/`

---

## D. Glossary

- **WER**: Word Error Rate - percentage of words transcribed incorrectly
- **VAD**: Voice Activity Detection - algorithm to detect when user is speaking
- **RTF**: Real-Time Factor - processing time / audio duration (RTF < 1 means faster than real-time)
- **AXUI**: macOS Accessibility UI element - API for interacting with application UI

---

[← Back to Overview](./README.md)
