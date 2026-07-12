// CanvasEditorView.swift
// Scribe — Full-screen canvas editing experience with premium tool palette

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
    @State private var canvasBackgroundColor = Color(.systemBackground)
    
    var body: some View {
        ZStack {
            // Background that matches the canvas — prevents black borders
            canvasBackgroundColor
                .ignoresSafeArea()
            
            // Canvas
            CanvasView(
                drawing: $viewModel.drawing,
                isDrawing: $viewModel.isDrawing,
                canvasSize: page.canvasSize,
                backgroundStyle: page.backgroundStyle,
                template: templateForPage,
                canvasMode: page.canvasMode,
                appearance: page.canvasAppearance,
                toolState: toolState,
                onDrawingChanged: { newDrawing in
                    viewModel.handleDrawingChanged(newDrawing)
                },
                onStrokeBegan: {
                    viewModel.strokeBegan()
                },
                onStrokeEnded: {
                    viewModel.strokeEnded()
                },
                onBackgroundColorResolved: { uiColor in
                    canvasBackgroundColor = Color(uiColor)
                }
            )
            .ignoresSafeArea()
            
            // Tool Palette Overlay
            if showToolPalette {
                VStack {
                    Spacer()
                    ToolPaletteView(viewModel: viewModel)
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
            resolveInitialBackground()
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
        HStack(spacing: 12) {
            // Close button
            Button {
                viewModel.save()
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.body.weight(.semibold))
                    .foregroundColor(.primary)
                    .frame(width: 40, height: 40)
                    .background(.ultraThinMaterial, in: Circle())
            }
            
            Spacer()
            
            // Undo/Redo
            HStack(spacing: 2) {
                Button {
                    viewModel.undo()
                } label: {
                    Image(systemName: "arrow.uturn.backward")
                        .font(.body)
                        .frame(width: 40, height: 40)
                }
                .disabled(!viewModel.canUndo)
                
                Button {
                    viewModel.redo()
                } label: {
                    Image(systemName: "arrow.uturn.forward")
                        .font(.body)
                        .frame(width: 40, height: 40)
                }
                .disabled(!viewModel.canRedo)
            }
            .foregroundColor(.primary)
            .background(.ultraThinMaterial, in: Capsule())
            
            // Page Settings
            Button {
                showPageSettings = true
            } label: {
                Image(systemName: "slider.horizontal.3")
                    .font(.body.weight(.medium))
                    .foregroundColor(.primary)
                    .frame(width: 40, height: 40)
                    .background(.ultraThinMaterial, in: Circle())
            }
            
            // More menu
            Menu {
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
                    toolState.fingerDrawingEnabled.toggle()
                } label: {
                    Label(
                        toolState.fingerDrawingEnabled ? "Pencil Only" : "Allow Finger Drawing",
                        systemImage: toolState.fingerDrawingEnabled ? "hand.raised.slash" : "hand.draw"
                    )
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.body.weight(.semibold))
                    .foregroundColor(.primary)
                    .frame(width: 40, height: 40)
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
    
    private func resolveInitialBackground() {
        switch page.canvasAppearance {
        case .dark:
            canvasBackgroundColor = Color(red: 0.11, green: 0.11, blue: 0.12)
        case .light:
            canvasBackgroundColor = Color(red: 1.0, green: 0.995, blue: 0.98)
        case .system:
            canvasBackgroundColor = Color(.systemBackground)
        }
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
    @State private var selectedAppearance: CanvasAppearance = .system
    
    var body: some View {
        NavigationStack {
            Form {
                titleSection
                appearanceSection
                backgroundSection
                canvasModeSection
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
                selectedAppearance = page.canvasAppearance
            }
        }
    }
    
    @ViewBuilder
    private var titleSection: some View {
        SwiftUI.Section("Title") {
            TextField("Page title", text: $title)
        }
    }
    
    @ViewBuilder
    private var appearanceSection: some View {
        SwiftUI.Section("Canvas Appearance") {
            ForEach(CanvasAppearance.allCases, id: \.self) { (appearance: CanvasAppearance) in
                Button {
                    selectedAppearance = appearance
                } label: {
                    HStack {
                        Image(systemName: appearance.systemImage)
                            .frame(width: 24)
                            .foregroundColor(.primary)
                        
                        Text(appearance.displayName)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        if selectedAppearance == appearance {
                            Image(systemName: "checkmark")
                                .foregroundColor(.accentColor)
                        }
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private var backgroundSection: some View {
        SwiftUI.Section("Background Pattern") {
            ForEach(BackgroundStyle.allCases, id: \.self) { (style: BackgroundStyle) in
                Button {
                    selectedBackground = style
                } label: {
                    HStack {
                        Image(systemName: style.systemImage)
                            .frame(width: 24)
                            .foregroundColor(.primary)
                        
                        Text(style.displayName)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        if selectedBackground == style {
                            Image(systemName: "checkmark")
                                .foregroundColor(.accentColor)
                        }
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private var canvasModeSection: some View {
        SwiftUI.Section("Canvas Mode") {
            ForEach(CanvasMode.allCases, id: \.self) { (mode: CanvasMode) in
                Button {
                    selectedMode = mode
                } label: {
                    HStack {
                        Image(systemName: mode.systemImage)
                            .frame(width: 24)
                            .foregroundColor(.primary)
                        
                        VStack(alignment: .leading) {
                            Text(mode.displayName)
                                .foregroundColor(.primary)
                            
                            Text(mode == .page
                                 ? "Fixed dimensions with page boundaries"
                                 : "Infinite canvas that grows as you draw")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        if selectedMode == mode {
                            Image(systemName: "checkmark")
                                .foregroundColor(.accentColor)
                        }
                    }
                }
            }
        }
    }
    
    private func applySettings() {
        let service = PageService(modelContext: modelContext)
        service.updateTitle(page, title: title)
        service.updateBackground(page, style: selectedBackground)
        service.updateCanvasMode(page, mode: selectedMode)
        service.updateAppearance(page, appearance: selectedAppearance)
    }
}
