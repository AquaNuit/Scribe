# Scribe — Architecture

## Overview

Scribe is a native iPadOS application built with SwiftUI, PencilKit, and Metal for professional-grade handwritten note-taking.

## System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     PRESENTATION LAYER                      │
│  SwiftUI Views + UIKit Integration (PKCanvasView, PDFView) │
├─────────────────────────────────────────────────────────────┤
│                     STATE MANAGEMENT                        │
│  @Observable ViewModels + NavigationRouter + ToolState      │
├─────────────────────────────────────────────────────────────┤
│                      SERVICE LAYER                          │
│  NotebookService, PageService, PDFImport/Export, Search     │
├─────────────────────────────────────────────────────────────┤
│                    RENDERING ENGINE                         │
│  PencilKit (ink) + Metal (backgrounds) + CoreGraphics      │
├─────────────────────────────────────────────────────────────┤
│                    PERSISTENCE LAYER                        │
│  SwiftData (models) + FileStore (assets) + CloudKit (sync) │
├─────────────────────────────────────────────────────────────┤
│                     AI LAYER (Future)                       │
│  Modular protocol-based services (OCR, Shape, Math, NLP)   │
└─────────────────────────────────────────────────────────────┘
```

## Key Patterns

- **Unidirectional data flow**: User Action → View → ViewModel → Service → SwiftData
- **@Observable** for state management (Observation framework, iPadOS 17+)
- **@Query** for reactive data fetching from SwiftData
- **UIViewRepresentable** bridge for PencilKit and PDFKit
- **Actor isolation** for thread-safe file operations (FileStore)
- **Command pattern** for undo/redo

## Technology Stack

| Layer | Technologies |
|:---|:---|
| UI | SwiftUI, UIKit interop |
| Drawing | PencilKit, CoreGraphics |
| Rendering | Metal (backgrounds, tiles) |
| Persistence | SwiftData, FileManager |
| Sync | CloudKit (via SwiftData) |
| AI | Vision, CoreML (future) |
| PDF | PDFKit |

## Module Dependency Graph

```
ScribeApp → RootView → SidebarView / ContentListView / DetailContainerView
                              ↓
                    NotebookDetailView → CanvasEditorView
                              ↓                    ↓
                    NotebookService       CanvasViewModel → CanvasView
                              ↓                    ↓              ↓
                         SwiftData          ToolState    PKCanvasView
                              ↓                              ↓
                        CloudKit                     PencilKit Engine
```
