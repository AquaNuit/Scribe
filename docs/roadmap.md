# Scribe — Development Roadmap

## Phase 1: Core Foundation ⏳ (Weeks 1-4)
**Status: Code Complete — Needs First Build**

- [x] Project structure + XcodeGen
- [x] SwiftData models
- [x] Navigation shell (3-column)
- [x] Notebook browser + creation
- [x] Canvas editor + PencilKit
- [x] Background patterns (8 types)
- [x] Tool palette + color picker
- [x] Undo/redo
- [x] Auto-save
- [x] Apple Pencil Pro support
- [x] GitHub Actions CI/CD
- [ ] First successful build
- [ ] Fix compilation errors
- [ ] Infinite canvas mode (whiteboard)

**Complexity:** High  
**Risk:** PencilKit ↔ infinite canvas integration  
**Milestone:** App builds and runs on iPad simulator  

---

## Phase 2: PDF & Export (Weeks 5-7)

- [x] PDF import (document → notebook)
- [x] PDF export (notebook → PDF)
- [ ] PDF annotation overlay (draw on PDFs)
- [ ] PDF merge
- [ ] PDF split
- [ ] Full-text search engine
- [ ] Export formats (PNG, JPEG, SVG)
- [ ] Share sheet integration

**Complexity:** Medium-High  
**Risk:** Coordinate mapping between PencilKit and PDF  
**Milestone:** Can import, annotate, and re-export a PDF  

---

## Phase 3: Cloud Sync (Weeks 8-10)

- [ ] SwiftData + CloudKit configuration
- [ ] Sync status UI indicators
- [ ] Conflict resolution for drawings
- [ ] Background sync via BGAppRefreshTask
- [ ] Backup and restore
- [ ] Data migration system

**Complexity:** High  
**Risk:** Requires paid Apple Developer account for CloudKit  
**Milestone:** Changes sync between two iPads  

---

## Phase 4: AI Infrastructure (Weeks 11-12)

- [x] AI service protocol layer
- [ ] OCR via Vision framework
- [ ] Shape recognition + beautification
- [ ] Math expression recognition
- [ ] Smart search (search within handwriting)

**Complexity:** Medium  
**Risk:** On-device ML model performance  
**Milestone:** Can recognize handwritten text  

---

## Phase 5: Polish & App Store (Weeks 13-15)

- [ ] Performance profiling and optimization
- [ ] Memory leak audit
- [ ] Accessibility audit (VoiceOver, Dynamic Type)
- [ ] Keyboard shortcuts
- [ ] Stage Manager / Split View testing
- [ ] App icon and branding
- [ ] App Store screenshots
- [ ] Privacy policy
- [ ] App Store submission

**Complexity:** Medium  
**Risk:** Edge cases in multi-window environments  
**Milestone:** App Store approval  

---

## Future (Post-v1)

- Metal custom brush engine
- Real-time collaboration
- Audio recording with time-synced notes
- Apple Intelligence integration
- Handwriting-to-text conversion
- Document scanner integration
- Widget support
- Shortcuts integration
