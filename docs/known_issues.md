# Scribe — Known Issues

> Track bugs, quirks, and workarounds here.

## Open Issues

### 🔴 Critical

_None currently_

### 🟡 Important

1. **Project not yet compiled** — First build may surface type errors or missing imports. Expected.

### 🟢 Minor

1. **Template JSON files not created** — The `Resources/Templates/` directory is referenced but template files are defined in code as `Template` structs instead.

## Resolved Issues

_None yet — project is pre-first-build_

## Known Limitations

1. **Free developer account** — Apps expire every 7 days when sideloaded via AltStore
2. **No CloudKit** — iCloud sync is architecturally ready but disabled until a paid developer account is available
3. **No Metal tile rendering** — Background patterns use CoreGraphics (adequate for v1, Metal planned for v2)
4. **Hackintosh USB detection** — iPad not detected via USB; using GitHub Actions for builds
