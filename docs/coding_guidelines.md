# Scribe — Coding Guidelines

## Swift Style

- **Swift 6** with strict concurrency checking enabled
- Use `final class` for all classes unless inheritance is needed
- Prefer `struct` over `class` where possible
- Use `@Observable` for view models, not `ObservableObject`
- Mark `@MainActor` on all SwiftData service classes and view models

## Naming

- Files named after the primary type they contain
- Services suffixed with `Service` (e.g., `NotebookService`)
- View models suffixed with `ViewModel`
- Protocols suffixed with `Protocol` (for AI services) or `Delegate`
- Enums use singular names (`ToolType`, not `ToolTypes`)

## Architecture Rules

1. **Views** should be thin — no business logic, just `@Query` and environment bindings
2. **Services** handle all business logic and data manipulation
3. **ViewModels** manage view-specific state and coordinate services
4. **Never** call `modelContext.save()` from a view — go through a service
5. **All file I/O** goes through `FileStore` (actor-isolated)

## SwiftData

- All relationships **must be optional** (CloudKit compatibility)
- **Never** use `@Attribute(.unique)` (CloudKit incompatible)
- Use `UUID` for all model identifiers
- Encode enum values as raw strings (for SwiftData storage)
- Always provide `FetchDescriptor` with sort descriptors

## PencilKit

- **PKCanvasView** must be wrapped in `UIViewControllerRepresentable`
- Avoid recreating PKCanvasView in `updateUIView` — configure once in `makeUIView`
- Use `PKCanvasViewDelegate` for drawing change callbacks
- Tool changes flow from SwiftUI (`ToolState`) → UIKit (`canvasView.tool`)
- Hide `PKToolPicker` — use custom SwiftUI tool palette

## Logging

- Use `Logger.category` (e.g., `Logger.canvas.info("...")`)
- Log at `.info` for normal operations
- Log at `.error` for recoverable errors
- Log at `.fault` for unrecoverable errors
- Never log sensitive user data

## Documentation

- Update `docs/agent_handoff.md` after every session
- Update `docs/implementation_status.md` when features are completed
- Update `docs/changelog.md` for user-facing changes
- Add ADRs to `docs/decisions.md` for significant technical choices

## Git

- Commit messages: `feat:`, `fix:`, `docs:`, `refactor:`, `test:`, `chore:`
- One logical change per commit
- Always run `xcodegen generate` after modifying `project.yml`
