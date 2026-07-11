# Scribe — Changelog

## [1.0.0] — 2026-07-11

### Added
- Initial project structure with XcodeGen
- SwiftData models: Notebook, Section, Page, Tag, MediaAttachment
- Template system with 8 built-in backgrounds
- Tool preset system with default configurations
- 3-column NavigationSplitView layout
- Sidebar navigation (Library, Favorites, Tags, Archive)
- Notebook browser with gradient cover cards
- Notebook creation with emoji, color, and template pickers
- Notebook detail view with sections and page grids
- Full-screen canvas editor with PencilKit integration
- 8 canvas background renderers (blank, lined, grid, dot grid, music staff, engineering, cornell, isometric)
- Floating tool palette with ink tools, erasers, lasso, ruler
- Custom color picker with 36 swatches and recent colors
- Brush size slider with visual preview
- Undo/redo engine (command pattern, 200 levels)
- Auto-save with 3-second debounce
- Apple Pencil Pro squeeze → eraser toggle
- Pencil pressure curve engine with presets (linear, soft, firm, calligraphy)
- Catmull-Rom stroke smoothing
- NotebookService with full CRUD + search
- PageService with CRUD, duplicate, reorder, move
- PDF import service
- PDF export service (page and notebook)
- PNG image export
- AI service protocol layer (OCR, shape recognition, math solver, summarization)
- Actor-based FileStore for asset management
- Settings views (pencil, canvas, storage, about)
- Design system (ScribeTheme)
- Color and View SwiftUI extensions
- PKDrawing extensions (thumbnail, merge, data size)
- Unified os.Logger system
- GitHub Actions CI/CD for unsigned IPA build
- Unit tests for NotebookService
- UI tests for core flows
- Full documentation system (10 docs)
