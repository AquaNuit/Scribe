# Scribe — Module Index

## App Layer
| File | Purpose |
|:---|:---|
| `App/ScribeApp.swift` | App entry point, ModelContainer setup |
| `App/RootView.swift` | Root NavigationSplitView layout |

## Models
| File | Purpose |
|:---|:---|
| `Models/Notebook.swift` | SwiftData notebook model |
| `Models/Section.swift` | SwiftData section model |
| `Models/Page.swift` | SwiftData page model with PKDrawing |
| `Models/Tag.swift` | SwiftData tag model |
| `Models/MediaAttachment.swift` | Media reference model |
| `Models/Template.swift` | Canvas template definitions |
| `Models/ToolPreset.swift` | Saved tool configurations |
| `Models/Enums/CanvasMode.swift` | Page vs whiteboard mode |
| `Models/Enums/BackgroundStyle.swift` | Canvas background patterns |
| `Models/Enums/ToolType.swift` | Drawing tool types |
| `Models/Enums/SortOrder.swift` | Sort order + MediaType |

## Core/Canvas
| File | Purpose |
|:---|:---|
| `Core/Canvas/CanvasView.swift` | SwiftUI ↔ UIKit canvas bridge |
| `Core/Canvas/CanvasViewController.swift` | UIKit controller for PKCanvasView |
| `Core/Canvas/CanvasViewModel.swift` | Canvas state + undo/redo |
| `Core/Canvas/CanvasBackgroundView.swift` | CoreGraphics background renderer |
| `Core/Canvas/InfiniteCanvasManager.swift` | Dynamic canvas expansion |

## Core/Pencil
| File | Purpose |
|:---|:---|
| `Core/Pencil/ToolState.swift` | Observable tool state |
| `Core/Pencil/PencilEngine.swift` | Pressure curves + tilt processing |
| `Core/Pencil/StrokeSmoothing.swift` | Catmull-Rom interpolation |

## Core/Documents
| File | Purpose |
|:---|:---|
| `Core/Documents/NotebookService.swift` | Notebook CRUD + search |
| `Core/Documents/PageService.swift` | Page CRUD + reorder + duplicate |

## Core/Storage
| File | Purpose |
|:---|:---|
| `Core/Storage/DataStore.swift` | ModelContainer factory |
| `Core/Storage/FileStore.swift` | Actor-based file storage |

## Core/PDF
| File | Purpose |
|:---|:---|
| `Core/PDF/PDFImportService.swift` | PDF import to notebook |
| `Core/PDF/PDFExportService.swift` | Notebook/page PDF export |

## Core/AI
| File | Purpose |
|:---|:---|
| `Core/AI/AIServiceProtocol.swift` | AI service protocols + manager |

## UI/Navigation
| File | Purpose |
|:---|:---|
| `UI/Navigation/NavigationRouter.swift` | Centralized navigation state |
| `UI/Navigation/SidebarView.swift` | Main sidebar |
| `UI/Navigation/ContentListView.swift` | Notebook grid list |
| `UI/Navigation/DetailContainerView.swift` | Detail panel + canvas overlay |

## UI/Notebooks
| File | Purpose |
|:---|:---|
| `UI/Notebooks/NotebookCoverView.swift` | Notebook cover card |
| `UI/Notebooks/NotebookDetailView.swift` | Notebook sections + pages |
| `UI/Notebooks/CreateNotebookSheet.swift` | New notebook creation flow |

## UI/Canvas
| File | Purpose |
|:---|:---|
| `UI/Canvas/CanvasEditorView.swift` | Full-screen canvas editor |
| `UI/Canvas/ToolPaletteView.swift` | Floating tool palette |
| `UI/Canvas/ColorPickerView.swift` | Color picker + brush size |

## UI/Components
| File | Purpose |
|:---|:---|
| `UI/Components/EmptyStateView.swift` | Reusable empty state |
| `UI/Components/ScribeTheme.swift` | Design system constants |

## UI/Settings
| File | Purpose |
|:---|:---|
| `UI/Settings/SettingsView.swift` | All settings views |

## Extensions
| File | Purpose |
|:---|:---|
| `Extensions/Color+Extensions.swift` | Hex ↔ Color conversion |
| `Extensions/View+Extensions.swift` | Card style, glass morphism |
| `Extensions/PKDrawing+Extensions.swift` | Thumbnail, merge, data size |

## Utilities
| File | Purpose |
|:---|:---|
| `Utilities/Constants.swift` | App-wide constants |
| `Utilities/Logger.swift` | os.Logger categories |
