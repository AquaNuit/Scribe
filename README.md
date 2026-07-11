# Scribe ✍️

> Professional-grade handwritten note-taking for iPad with full Apple Pencil support.

![Platform](https://img.shields.io/badge/platform-iPadOS%2018+-blue)
![Swift](https://img.shields.io/badge/Swift-6.0-orange)
![PencilKit](https://img.shields.io/badge/PencilKit-Integrated-green)

## Features

- **Apple Pencil Pro** — Pressure sensitivity, tilt shading, hover preview, squeeze shortcuts
- **Rich Tool Palette** — Fountain pen, pencil, marker, highlighter, erasers, lasso, ruler
- **Infinite Canvas** — Page mode and whiteboard mode with smooth zoom/pan
- **8 Background Patterns** — Blank, lined, grid, dot grid, music staff, engineering graph, Cornell, isometric
- **Notebook System** — Notebooks → Sections → Pages with favorites, tags, archive
- **PDF Import/Export** — Import PDFs, annotate, and export
- **Auto-Save** — 3-second debounce with undo/redo (200 levels)
- **AI-Ready** — Modular service layer for future OCR, shape recognition, math solving
- **Offline-First** — All data stored locally, CloudKit-ready architecture

## Quick Start

### Prerequisites

- macOS with Xcode 16+
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) (`brew install xcodegen`)

### Build

```bash
cd Scribe/
xcodegen generate
open Scribe.xcodeproj
# Build for iPad simulator or device
```

### GitHub Actions (No Mac Required)

Push to `main` → GitHub Actions builds an unsigned IPA → Download from Artifacts → Install via [AltStore](https://altstore.io).

See [.github/workflows/build-ipa.yml](.github/workflows/build-ipa.yml) for details.

## Architecture

```
Scribe/
├── App/                   # Entry point, lifecycle
├── Core/
│   ├── Canvas/            # PencilKit canvas + infinite canvas
│   ├── Pencil/            # Pencil input processing + tool state
│   ├── Documents/         # Notebook/page services
│   ├── Storage/           # SwiftData + file storage
│   ├── PDF/               # PDF import/export
│   └── AI/                # AI service protocols (future)
├── Models/                # SwiftData models + enums
├── UI/                    # SwiftUI views by feature
├── Extensions/            # Type extensions
├── Utilities/             # Constants, logging
├── Resources/             # Templates, localization
└── docs/                  # Living documentation
```

## Documentation

| Document | Purpose |
|:---|:---|
| [architecture.md](docs/architecture.md) | System architecture |
| [implementation_status.md](docs/implementation_status.md) | Feature status tracker |
| [agent_handoff.md](docs/agent_handoff.md) | **Start here** for AI agent development |
| [coding_guidelines.md](docs/coding_guidelines.md) | Code style and patterns |
| [decisions.md](docs/decisions.md) | Architectural decisions |
| [roadmap.md](docs/roadmap.md) | Development roadmap |
| [api_reference.md](docs/api_reference.md) | Service API reference |
| [module_index.md](docs/module_index.md) | File-by-file index |

## Tech Stack

SwiftUI • UIKit • PencilKit • PDFKit • SwiftData • CoreGraphics • Metal (planned) • CloudKit (planned) • Vision (planned) • CoreML (planned)

## License

Private project — all rights reserved.
