# OpenFlow Dictation

**100% Offline, Privacy-First Voice Dictation for macOS**

OpenFlow Dictation is a lightweight, native macOS application that provides intelligent voice-to-text dictation with AI-powered text refinement. Unlike cloud-based solutions that capture screenshots and send voice data to remote servers, OpenFlow Dictation processes everything locally on your Mac, ensuring complete privacy and zero latency.

## Features

- 100% offline processing (no internet required)
- Native Swift implementation for optimal performance
- IDE integration for developers (Cursor, Windsurf, VS Code)
- Open source (MIT License) - free forever
- Lightweight (<100MB download, ~150MB RAM usage)
- Apple Silicon optimized

## Requirements

- macOS 14 Sonoma (2023) or later
- Apple Silicon (M1/M2/M3/M4) only
- Microphone access
- Accessibility permissions (for text injection)

## Installation

### From Source

1. Clone the repository
2. Run the setup script:
   ```bash
   ./Scripts/setup_dev.sh
   ```
3. Download a Whisper model:
   ```bash
   ./Scripts/download_models.sh ggml-base.en.bin
   ```
4. Build and run:
   ```bash
   swift build
   swift run
   ```

### Build Release

```bash
./Scripts/build_release.sh
```

This creates `dist/OpenFlow.app` which you can drag to Applications.

## Usage

1. Launch OpenFlow (it runs in the menu bar)
2. Grant microphone and accessibility permissions when prompted
3. Press `⌘⇧Space` to start/stop dictation
4. Speak naturally - text will be typed into the active text field

## IDE Integration

OpenFlow provides special features when using Cursor or Windsurf:

- **File Tagging**: Say "tag filename" to insert `@filename`
- **Command Injection**: Say "explain this" to prepend "Explain this code:"

## Architecture

The project is organized as follows:

```
OpenFlow/
├── App/                    # App entry point and lifecycle
├── Core/
│   ├── Audio/             # Audio capture with AVAudioEngine
│   ├── Transcription/     # Whisper.cpp integration
│   └── TextProcessing/    # Text formatting and processing
├── Features/
│   ├── Dictation/         # Main dictation service
│   ├── IDEIntegration/    # IDE-specific features
│   └── Settings/          # Preferences UI
└── Utilities/             # Helper utilities
```

## Development

See the [plan documentation](./docs/plan/) for detailed project roadmap:

- [Phase 1: MVP](./docs/plan/phase-1-mvp.md) - Foundation and core dictation
- [Phase 2: Enhanced Features](./docs/plan/phase-2-enhanced.md) - Translation and advanced features
- [Technical Specifications](./docs/plan/technical-specs.md) - Implementation details

## License

MIT License - see LICENSE file for details

## Contributing

Contributions are welcome! Please see [docs/CONTRIBUTING.md](./docs/CONTRIBUTING.md) for guidelines.
