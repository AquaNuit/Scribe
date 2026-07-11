// CanvasEditorView.swift
// Scribe — Full-screen canvas editing experience with tool palette

import SwiftUI
import PencilKit

struct CanvasEditorView: View {
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(ToolState.self) private var toolState
    
    let page: Page
    
    @State private var viewModel = CanvasViewModel()
    @State private var showToolPalette = true
    @State private var showPageSettings = false
    @State private var showExportSheet = false
    
    var body: some View {
        ZStack {
            // Canvas
            CanvasView(
                drawing: $viewModel.drawing,
                isDrawing: $viewModel.isDrawing,
                canvasSize: page.canvasSize,
                backgroundStyle: page.backgroundStyle,
                template: templateForPage,
                toolState: toolState,
                onDrawingChanged: { newDrawing in
                    viewModel.handleDrawingChanged(newDrawing)
                }
            )
            .ignoresSafeArea()
            
            // Tool Palette Overlay
            if showToolPalette {
                VStack {
                    Spacer()
                    ToolPaletteView()
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                .padding(.bottom, 8)
            }
            
            // Top Bar
            VStack {
                topBar
                Spacer()
            }
        }
        .persistentSystemOverlays(.hidden)
        .onAppear {
            viewModel.loadPage(page)
        }
        .onDisappear {
            viewModel.save()
        }
        .sheet(isPresented: $showPageSettings) {
            PageSettingsSheet(page: page)
        }
    }
    
    // MARK: - Top Bar
    
    private var topBar: some View {
        HStack(spacing: 16) {
            // Close button
            Button {
                viewModel.save()
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.primary)
                    .frame(width: 36, height: 36)
                    .background(.ultraThinMaterial, in: Circle())
            }
            
            Spacer()
            
            // Page title
            Text(page.title.isEmpty ? "Untitled" : page.title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
            
            Spacer()
            
            // Undo/Redo
            HStack(spacing: 4) {
                Button {
                    viewModel.undo()
                } label: {
                    Image(systemName: "arrow.uturn.backward")
                        .font(.body)
                        .frame(width: 36, height: 36)
                }
                .disabled(!viewModel.canUndo)
                
                Button {
                    viewModel.redo()
                } label: {
                    Image(systemName: "arrow.uturn.forward")
                        .font(.body)
                        .frame(width: 36, height: 36)
                }
                .disabled(!viewModel.canRedo)
            }
            .foregroundStyle(.primary)
            .background(.ultraThinMaterial, in: Capsule())
            
            // More menu
            Menu {
                Button {
                    showPageSettings = true
                } label: {
                    Label("Page Settings", systemImage: "doc.badge.gearshape")
                }
                
                Button {
                    withAnimation { showToolPalette.toggle() }
                } label: {
                    Label(
                        showToolPalette ? "Hide Tool Palette" : "Show Tool Palette",
                        systemImage: showToolPalette ? "paintpalette.fill" : "paintpalette"
                    )
                }
                
                Button {
                    toolState.toggleEraser()
                } label: {
                    Label(
                        toolState.currentToolType.isEraser ? "Switch to Pen" : "Eraser",
                        systemImage: toolState.currentToolType.isEraser ? "pencil" : "eraser"
                    )
                }
                
                Divider()
                
                Button {
                    // Future: export
                } label: {
                    Label("Export", systemImage: "square.and.arrow.up")
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.primary)
                    .frame(width: 36, height: 36)
                    .background(.ultraThinMaterial, in: Circle())
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }
    
    // MARK: - Helpers
    
    private var templateForPage: Template {
        Template.allBuiltIn.first { $0.backgroundStyle == page.backgroundStyle } ?? .blank
    }
}

// MARK: - Page Settings Sheet

struct PageSettingsSheet: View {
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    let page: Page
    @State private var title: String = ""
    @State private var selectedBackground: BackgroundStyle = .blank
    @State private var selectedMode: CanvasMode = .page
    
    var body: some View {
        NavigationStack {
            Form {
                SwiftUI.Section("Title") {
                    TextField("Page title", text: $title)
                }
                
                SwiftUI.Section("Background") {
                    ForEach(BackgroundStyle.allCases) { style in
                        Button {
                            selectedBackground = style
                        } label: {
                            HStack {
                                Image(systemName: style.systemImage)
                                    .frame(width: 24)
                                    .foregroundStyle(.primary)
                                
                                Text(style.displayName)
                                    .foregroundStyle(.primary)
                                
                                Spacer()
                                
                                if selectedBackground == style {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(.accentColor)
                                }
                            }
                        }
                    }
                }
                
                SwiftUI.Section("Canvas Mode") {
                    ForEach(CanvasMode.allCases) { mode in
                        Button {
                            selectedMode = mode
                        } label: {
                            HStack {
                                Image(systemName: mode.systemImage)
                                    .frame(width: 24)
                                    .foregroundStyle(.primary)
                                
                                VStack(alignment: .leading) {
                                    Text(mode.displayName)
                                        .foregroundStyle(.primary)
                                    
                                    Text(mode == .page
                                         ? "Fixed dimensions with page boundaries"
                                         : "Infinite canvas that grows as you draw")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                
                                Spacer()
                                
                                if selectedMode == mode {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(.accentColor)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Page Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        applySettings()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
            .onAppear {
                title = page.title
                selectedBackground = page.backgroundStyle
                selectedMode = page.canvasMode
            }
        }
    }
    
    private func applySettings() {
        let service = PageService(modelContext: modelContext)
        service.updateTitle(page, title: title)
        service.updateBackground(page, style: selectedBackground)
        service.updateCanvasMode(page, mode: selectedMode)
    }
}
