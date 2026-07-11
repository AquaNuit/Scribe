# Scribe — Agent Handoff

> This file is the primary reference for any AI agent continuing development on Scribe.
> **Always read this file first before making changes.**

## Current Project Status

**Phase:** Phase 1 — Core Foundation (Complete)
**Build Status:** Ready for XcodeGen → Xcode → Build
**Last Session:** 2026-07-11

## Completed Features

- ✅ Full project structure with XcodeGen
- ✅ SwiftData models (Notebook, Section, Page, Tag, MediaAttachment)
- ✅ 3-column NavigationSplitView layout
- ✅ Sidebar navigation (Library, Favorites, Tags, Archive)
- ✅ Notebook browser with cover grid
- ✅ Notebook creation sheet (emoji, color, template)
- ✅ Notebook detail view with sections and page thumbnails
- ✅ Full-screen canvas editor with PencilKit
- ✅ 8 canvas background patterns
- ✅ Floating tool palette (pen, pencil, marker, highlighter, erasers, lasso, ruler)
- ✅ Custom color picker with swatches
- ✅ Brush size slider
- ✅ Undo/redo with command pattern (200 levels)
- ✅ Auto-save (3-second debounce)
- ✅ Apple Pencil Pro squeeze support
- ✅ Pressure curve engine
- ✅ Catmull-Rom stroke smoothing
- ✅ PDF import/export services
- ✅ AI service protocol layer (future-ready)
- ✅ Settings views (pencil, canvas, storage, about)
- ✅ FileStore for asset management
- ✅ GitHub Actions CI/CD for unsigned IPA
- ✅ Unit tests and UI tests
- ✅ Full documentation system

## Active Branch

`main`

## Outstanding Bugs

None known — project has not been compiled yet. First build may surface issues.

## Next Recommended Tasks

1. **Build the project** — Run `xcodegen generate` in the Scribe/ directory, then open in Xcode and fix any compilation errors
2. **PDF annotation overlay** — Implement PKCanvasView overlay on PDFView for annotation
3. **Infinite canvas mode** — Wire up InfiniteCanvasManager to dynamically expand canvas in whiteboard mode
4. **Metal tile renderer** — Replace CoreGraphics background rendering with Metal for better zoom performance
5. **Search engine** — Full-text search across notebook titles, page titles, and tags
6. **Image insertion** — Allow inserting images from photo library onto canvas

## Recent Architectural Changes

- Used `@Observable` (Observation framework) instead of `ObservableObject` for all view models
- Chose XcodeGen over manual .xcodeproj for CI/CD reproducibility
- PencilKit as primary ink engine (not custom Metal ink) for v1 reliability
- SwiftData without CloudKit for v1 (CloudKit requires paid developer account)
- Unsigned IPA workflow — AltStore handles re-signing

## Important Implementation Notes

- **All SwiftData relationships are optional** (CloudKit requirement)
- **No `@Attribute(.unique)`** used anywhere (CloudKit incompatible)
- **ToolState and NavigationRouter** are `@Observable` environment objects injected at app root
- **CanvasView** uses `UIViewControllerRepresentable` (not `UIViewRepresentable`) because the canvas stack requires a UIViewController for proper lifecycle management
- **PKToolPicker** is hidden — we use a custom SwiftUI tool palette instead
- **Drawing data** stored as `Data` (serialized PKDrawing) in SwiftData, not as a file
- **Thumbnails** stored as JPEG `Data` in SwiftData for fast list rendering
- **FileStore** is an actor for thread-safe file operations

## Files Modified in Last Session

All files are new (initial implementation):

```
Scribe/
├── project.yml
├── .github/workflows/build-ipa.yml
├── Scribe/App/ (ScribeApp, RootView, Info.plist, entitlements, assets)
├── Scribe/Models/ (Notebook, Section, Page, Tag, MediaAttachment, Template, ToolPreset, Enums/)
├── Scribe/Core/Canvas/ (CanvasView, CanvasViewController, CanvasViewModel, CanvasBackgroundView, InfiniteCanvasManager)
├── Scribe/Core/Pencil/ (ToolState, PencilEngine, StrokeSmoothing)
├── Scribe/Core/Documents/ (NotebookService, PageService)
├── Scribe/Core/Storage/ (DataStore, FileStore)
├── Scribe/Core/PDF/ (PDFImportService, PDFExportService)
├── Scribe/Core/AI/ (AIServiceProtocol)
├── Scribe/UI/Navigation/ (NavigationRouter, SidebarView, ContentListView, DetailContainerView)
├── Scribe/UI/Notebooks/ (NotebookCoverView, NotebookDetailView, CreateNotebookSheet)
├── Scribe/UI/Canvas/ (CanvasEditorView, ToolPaletteView, ColorPickerView)
├── Scribe/UI/Components/ (EmptyStateView, ScribeTheme)
├── Scribe/UI/Settings/ (SettingsView)
├── Scribe/Extensions/ (Color+, View+, PKDrawing+)
├── Scribe/Utilities/ (Constants, Logger)
├── Tests/ (UnitTests, UITests)
└── docs/ (architecture, implementation_status, agent_handoff, etc.)
```

## Quick Start for New Agents

```bash
cd Scribe/
# Install xcodegen if not present
brew install xcodegen
# Generate Xcode project
xcodegen generate
# Open in Xcode
open Scribe.xcodeproj
# Build for iPad simulator
xcodebuild build -scheme Scribe -destination 'platform=iOS Simulator,name=iPad Pro 13-inch (M4)'
```
