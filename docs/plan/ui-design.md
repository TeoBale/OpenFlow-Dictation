# User Interface Design

---

## Visual Style

- **Minimalist**: Non-intrusive, unobtrusive
- **Native**: macOS-native look and feel
- **Lightweight**: Small memory footprint, fast startup

---

## Components

### 1. Menubar Icon

- Status indicator (idle/listening/processing)
- Click to show menu:
  - Start/Stop Dictation
  - Settings...
  - Models...
  - Recent Transcriptions
  - Help
  - Quit

### 2. Floating Overlay

- Appears when dictation active
- Shows:
  - Live waveform
  - Transcription preview (last 50 characters)
  - Status (Listening/Processing/Ready)
  - Cancel button (X)
- Position: Near cursor or fixed position (configurable)
- Size: 200x80px, semi-transparent

### 3. Settings Window

- **General Tab:**
  - Hotkey configuration
  - Default language
  - Model selection
  - Audio input device
- **Dictation Tab:**
  - Filler word list
  - Auto-punctuation toggle
  - Backtrack handling toggle
  - Voice Activity Detection settings
- **Dictionary Tab:**
  - Word list editor
  - Import/Export
- **IDE Tab:**
  - Enable/disable IDE integration
  - IDE-specific settings
- **About Tab:**
  - Version info
  - License
  - Open source credits

---

[← Back to Overview](./README.md)
