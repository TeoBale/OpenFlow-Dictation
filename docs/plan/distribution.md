# Distribution & Release Strategy

---

## Release Channels

**No Apple Developer Program Required** - This project uses free distribution methods:

### 1. Homebrew (Primary - Recommended)

- Custom tap: `brew install openflow-dictation/tap/openflow`
- Builds from source on user's machine (no notarization needed)
- Submit to homebrew-core after popularity
- **Best user experience**: Simple install command, automatic updates

### 2. GitHub Releases (Secondary)

- Source code with build instructions
- Unsigned .dmg for users who want pre-built binary
- Release notes with changelog
- Users bypass Gatekeeper: Right-click → "Open" → "Open" (one-time)
- Automated via GitHub Actions

### 3. Build from Source (For developers)

- Clone repo, run build script
- Full control over build process
- No Gatekeeper warnings (locally built)

---

## Versioning

- **Semantic Versioning**: MAJOR.MINOR.PATCH
- **Initial Release**: 0.1.0 (MVP)
- **Stable Release**: 1.0.0 (after Phase 3)

---

## Update Mechanism

**Phase 1-2**: Manual updates (check GitHub releases)
**Phase 3+**: Optional Sparkle framework integration for auto-updates

---

## Development Workflow

### Build Requirements

- macOS 14 Sonoma or later
- Xcode 15.0 or later
- Swift 5.9 or later
- Apple Silicon Mac (M1/M2/M3/M4)

### Development Setup

```bash
# Clone repository
git clone https://github.com/[username]/openflow-dictation.git
cd openflow-dictation

# Download models
./Scripts/download_models.sh

# Open in Xcode
open OpenFlow.xcodeproj

# Build
Cmd+B

# Run
Cmd+R
```

### Testing Strategy

**Unit Tests:**
- Text processing functions
- Audio buffer handling
- Dictionary management

**Integration Tests:**
- End-to-end dictation flow
- IDE integration (mocked)
- Settings persistence

**Manual Testing:**
- Real-world dictation scenarios
- IDE compatibility testing
- Performance benchmarking

### CI/CD Pipeline

**GitHub Actions Workflow:**
1. **Build**: Compile on macOS runner
2. **Test**: Run unit tests
3. **Package**: Create unsigned .dmg with create-dmg
4. **Release**: Upload to GitHub releases with notes (unsigned binaries)

**Note**: No notarization step required - distribution via Homebrew (builds from source) and unsigned GitHub releases.

---

[← Back to Overview](./README.md)
