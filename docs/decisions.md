# Scribe — Architectural Decisions

## ADR-001: XcodeGen over manual .xcodeproj

**Decision:** Use XcodeGen to generate the Xcode project from `project.yml`.

**Rationale:** 
- .xcodeproj files are opaque XML that causes merge conflicts
- XcodeGen makes the project structure declarative and diffable
- Essential for GitHub Actions CI/CD (reproducible builds)
- Easy for AI agents to modify

**Trade-offs:** Requires installing XcodeGen before building.

---

## ADR-002: PencilKit over custom Metal ink engine (v1)

**Decision:** Use PencilKit as the primary ink engine for v1.

**Rationale:**
- PencilKit provides <10ms latency out of the box
- Built-in pressure sensitivity, tilt, and prediction
- PKToolPicker and PKLassoTool for free
- Saves 2-3 months of development time vs custom Metal ink

**Trade-offs:** Less customization for exotic brush types. Plan to add Metal custom brushes in v2.

---

## ADR-003: @Observable over ObservableObject

**Decision:** Use the Observation framework (@Observable) for all view models.

**Rationale:**
- More efficient — views only re-render when accessed properties change
- Cleaner syntax — no @Published annotations needed
- Works naturally with SwiftUI environment

**Trade-offs:** Requires iPadOS 17+ minimum.

---

## ADR-004: SwiftData over Core Data

**Decision:** Use SwiftData for persistence.

**Rationale:**
- Native Swift integration, no Objective-C bridging
- Automatic CloudKit sync (when enabled)
- @Query for reactive UI updates
- Simpler migration story

**Trade-offs:** Less mature than Core Data; some edge cases with relationships.

---

## ADR-005: Unsigned IPA with AltStore sideloading

**Decision:** Build unsigned IPAs via GitHub Actions, install via AltStore.

**Rationale:**
- User has no paid Apple Developer account
- Hackintosh can't detect iPad via USB
- GitHub Actions provides real macOS runners
- AltStore handles development signing

**Trade-offs:** App expires every 7 days with free account. Must rebuild and reinstall weekly.

---

## ADR-006: Custom tool palette over PKToolPicker

**Decision:** Build a custom SwiftUI tool palette instead of using PKToolPicker.

**Rationale:**
- PKToolPicker is rigid in layout and appearance
- Custom palette allows brand-consistent design
- More control over tool organization and quick-access behavior
- Better integration with SwiftUI state

**Trade-offs:** Must manually manage tool ↔ PKCanvasView.tool synchronization.

---

## ADR-007: Drawing data stored in SwiftData (not files)

**Decision:** Store serialized PKDrawing data as `Data` blobs in SwiftData.

**Rationale:**
- Atomic persistence — drawing and metadata saved together
- Automatic CloudKit sync of drawing data
- Simpler than managing separate files per page
- Works well for typical drawing sizes (1-500KB)

**Trade-offs:** Very large drawings (>10MB) may impact SwiftData performance. Monitor and potentially move to file-based storage for large canvases.

---

## ADR-008: All SwiftData relationships optional

**Decision:** All `@Relationship` properties are optional.

**Rationale:** CloudKit cannot guarantee atomic relationship processing. Optional relationships prevent crashes during sync.

**Trade-offs:** Must handle nil relationships in code.
