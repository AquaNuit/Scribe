# Scribe — API Reference

## Services

### NotebookService

```swift
@MainActor final class NotebookService

// Create
func createNotebook(title: String, coverColor: String, emoji: String?, template: Template) -> Notebook

// Read
func fetchAllNotebooks(sortBy: SortOrder, includeArchived: Bool) throws -> [Notebook]
func fetchFavorites() throws -> [Notebook]
func fetchArchived() throws -> [Notebook]
func searchNotebooks(query: String) throws -> [Notebook]

// Update
func updateNotebook(_ notebook: Notebook, title: String?, coverColor: String?, emoji: String?)
func toggleFavorite(_ notebook: Notebook)
func archiveNotebook(_ notebook: Notebook)
func unarchiveNotebook(_ notebook: Notebook)

// Delete
func deleteNotebook(_ notebook: Notebook)
```

### PageService

```swift
@MainActor final class PageService

func createPage(in section: Section, title: String, backgroundStyle: BackgroundStyle, canvasMode: CanvasMode, atIndex: Int?) -> Page
func updateDrawing(_ page: Page, drawing: PKDrawing)
func updateTitle(_ page: Page, title: String)
func updateBackground(_ page: Page, style: BackgroundStyle)
func duplicatePage(_ page: Page) -> Page?
func movePage(_ page: Page, to section: Section)
func reorderPages(in section: Section, fromOffsets: IndexSet, toOffset: Int)
func deletePage(_ page: Page)
```

### PDFImportService

```swift
@MainActor final class PDFImportService

func importPDF(from url: URL, notebookTitle: String?) async throws -> Notebook
```

### PDFExportService

```swift
final class PDFExportService

static func exportPage(_ page: Page) -> Data?
static func exportNotebook(_ notebook: Notebook) -> Data?
static func exportPageAsImage(_ page: Page, scale: CGFloat) -> UIImage?
```

## State Objects

### ToolState

```swift
@Observable final class ToolState

var currentToolType: ToolType
var currentColorHex: String
var currentLineWidth: CGFloat
var isRulerActive: Bool
var fingerDrawingEnabled: Bool
var recentColors: [String]
var presets: [ToolPreset]

func selectTool(_ type: ToolType)
func selectPreset(_ preset: ToolPreset)
func toggleEraser()
func switchToPreviousTool()
func selectColor(_ hex: String)
```

### NavigationRouter

```swift
@Observable final class NavigationRouter

var selectedSidebarItem: SidebarItem
var selectedNotebook: Notebook?
var selectedPage: Page?
var isCanvasPresented: Bool
var searchQuery: String

func navigateToNotebook(_ notebook: Notebook)
func navigateToPage(_ page: Page)
func navigateToPage(_ page: Page, in notebook: Notebook)
func dismissCanvas()
```

### CanvasViewModel

```swift
@Observable final class CanvasViewModel

var drawing: PKDrawing
var isDrawing: Bool
var isDirty: Bool
var canUndo: Bool
var canRedo: Bool

func loadPage(_ page: Page)
func handleDrawingChanged(_ newDrawing: PKDrawing)
func save()
func undo()
func redo()
```

## AI Protocols

```swift
protocol AIServiceProtocol
protocol OCRServiceProtocol: AIServiceProtocol
protocol ShapeRecognitionServiceProtocol: AIServiceProtocol
protocol MathSolverServiceProtocol: AIServiceProtocol
protocol SummarizationServiceProtocol: AIServiceProtocol
```
