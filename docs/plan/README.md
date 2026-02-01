# OpenFlow Dictation - Product Overview

> **100% Offline, Privacy-First Voice Dictation for macOS**  
> *Open source, self-hostable alternative to WisprFlow and similar AI dictation systems*

---

## Executive Summary

OpenFlow Dictation is a lightweight, native macOS application that provides intelligent voice-to-text dictation with AI-powered text refinement. Unlike cloud-based solutions that capture screenshots and send voice data to remote servers, OpenFlow Dictation processes everything locally on your Mac, ensuring complete privacy and zero latency.

**Key Differentiators:**
- 100% offline processing (no internet required)
- Native Swift implementation for optimal performance
- IDE integration for developers (Cursor, Windsurf, VS Code)
- Open source (MIT License) - free forever, no paid features
- Lightweight (<100MB download, ~150MB RAM usage)
- Apple Silicon optimized

---

## Core Principles

1. **Privacy First**: No cloud processing, no data collection, no screenshots
2. **Performance**: Sub-second latency, minimal resource usage
3. **Universal Integration**: Works in any app with a text field
4. **Developer-Friendly**: Special features for coding workflows
5. **Open Source**: Community-driven, transparent development

---

## Product Requirements

### Technical Specifications

| Specification | Requirement |
|--------------|-------------|
| **Platform** | macOS 14 Sonoma (2023) or later |
| **Architecture** | Apple Silicon (M1/M2/M3/M4) only |
| **Memory Usage** | <200MB RAM during active dictation |
| **Disk Space** | <100MB app size + models |
| **Latency** | <500ms from speech to text output |
| **Languages** | 99+ languages (via Whisper models) |
| **Distribution** | GitHub Releases, Homebrew |
| **License** | MIT License |

### Supported IDEs (Phase 1)

- **Cursor** - File tagging, command injection
- **Windsurf** - File tagging, command injection  
- **VS Code** - Basic text injection (optional Phase 2 extension)

---

## Project Structure

```
OpenFlow Dictation/
├── OpenFlow/
│   ├── App/
│   │   ├── OpenFlowApp.swift              # App entry point
│   │   └── AppDelegate.swift              # Lifecycle management
│   ├── Core/
│   │   ├── Audio/
│   │   │   ├── AudioCaptureManager.swift  # AVAudioEngine wrapper
│   │   │   └── AudioBufferProcessor.swift # Real-time audio processing
│   │   ├── Transcription/
│   │   │   ├── WhisperEngine.swift        # whisper.cpp integration
│   │   │   ├── TranscriptionSession.swift # Session management
│   │   │   └── TranscriptionResult.swift  # Result data model
│   │   └── TextProcessing/
│   │       ├── TextFormatter.swift        # Filler removal, punctuation
│       │   └── PostProcessor.swift        # Advanced text processing
│   ├── Features/
│   │   ├── Dictation/
│   │   │   ├── DictationService.swift     # Main orchestration
│   │   │   ├── DictationOverlay.swift     # Floating UI
│   │   │   └── HotkeyManager.swift        # Global hotkey handler
│   │   ├── IDEIntegration/
│   │   │   ├── IDEIntegrationService.swift # IDE detection & integration
│   │   │   ├── CursorAdapter.swift         # Cursor-specific features
│   │   │   └── WindsurfAdapter.swift       # Windsurf-specific features
│   │   └── Settings/
│   │       ├── SettingsView.swift          # Preferences UI
│   │       └── DictionaryEditor.swift      # Custom words editor
│   ├── Models/
│   │   └── WhisperModels/                  # .bin model files (git-lfs)
│   ├── Resources/
│   │   ├── Assets.xcassets/
│   │   └── Info.plist
│   └── Utilities/
│       ├── AccessibilityHelpers.swift
│       ├── KeyboardSimulator.swift
│       └── PermissionManager.swift
├── Scripts/
│   ├── download_models.sh                  # Model downloader
│   ├── build_release.sh                    # Release builder
│   └── setup_dev.sh                        # Dev environment setup
├── .github/
│   └── workflows/
│       ├── build.yml                       # CI/CD
│       └── release.yml                     # Release automation
├── Tests/
│   └── OpenFlowTests/
├── docs/
│   ├── INSTALL.md
│   ├── CONTRIBUTING.md
│   └── API.md
├── Package.swift
├── README.md
├── LICENSE (MIT)
└── plan.md (this file)
```

---

## Quick Navigation

- [Phase 1: MVP (Weeks 1-8)](./phase-1-mvp.md) - Foundation and core dictation
- [Phase 2: Enhanced Features (Weeks 9-16)](./phase-2-enhanced.md) - Translation and advanced features
- [Phase 3: Community & Ecosystem (Weeks 17-24)](./phase-3-community.md) - Documentation and distribution
- [Phase 4: Future Enhancements](./phase-4-future.md) - Post-launch features
- [Technical Specifications](./technical-specs.md) - Detailed feature specs and implementation
- [Architecture](./architecture.md) - Technology stack and system design
- [User Interface Design](./ui-design.md) - UI components and design principles
- [Distribution Strategy](./distribution.md) - Release channels and development workflow
- [Security & Permissions](./security.md) - Security model and required permissions
- [Resources & Costs](./resources.md) - Team, timeline, and budget
- [Competitive Analysis](./analysis.md) - Market analysis and success metrics
- [Risk Assessment](./analysis.md#risk-assessment) - Technical and project risks
- [Appendix](./appendix.md) - Benchmarks, shortcuts, file formats
- [Open Questions](./open-questions.md) - Future considerations
- [Conclusion](./conclusion.md) - Summary and next steps

---

*Plan Version: 1.0*  
*Last Updated: February 2026*  
*Status: Ready for Development*
