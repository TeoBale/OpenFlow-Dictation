# Phase 1: MVP (Weeks 1-8)

**Goal**: Core dictation with basic IDE support

---

## Week 1-2: Foundation

- [ ] Xcode project setup with Swift Package Manager
- [ ] AVAudioEngine integration for audio capture
- [ ] whisper.cpp Swift bindings and integration
- [ ] Basic audio-to-text pipeline (microphone → Whisper → clipboard)
- [ ] Microphone permission handling
- [ ] Menubar app architecture

**Deliverable**: Basic transcription to clipboard

---

## Week 3-4: Core Dictation

- [ ] Global hotkey system (default: ⌘ + Shift + Space)
- [ ] Visual overlay UI (floating transcription window)
- [ ] Text injection via Apple Events (works in any text field)
- [ ] Push-to-talk and toggle modes
- [ ] Audio visualization (waveform)
- [ ] Settings UI (model selection, hotkey, language)

**Deliverable**: Full dictation in any app

---

## Week 5-6: Rule-Based Processing

- [ ] Filler word removal ("um", "uh", "like", "you know")
- [ ] Auto-punctuation (periods, commas, question marks based on pauses)
- [ ] Basic capitalization (sentence start, proper nouns from dictionary)
- [ ] Custom dictionary support (user-defined words)
- [ ] Backtrack handling ("actually...", "I mean...")

**Deliverable**: Polished text output

---

## Week 7-8: IDE Integration (Simple)

- [ ] IDE detection via accessibility APIs (active app identification)
- [ ] Cursor integration:
  - File tagging: "tag [filename]" → simulates @ + types filename
  - Basic command injection for common prompts
- [ ] Windsurf integration (similar to Cursor)
- [ ] "Screen Reader Mode" detection and usage

**Deliverable**: Developer-friendly dictation

---

## Phase 1 Completion

Fully functional offline dictation app with IDE support

---

[← Back to Overview](./README.md) | [Next: Phase 2 →](./phase-2-enhanced.md)
