// ToolPaletteView.swift
// Scribe — Premium floating tool palette for the canvas editor

import SwiftUI

struct ToolPaletteView: View {
    
    var viewModel: CanvasViewModel?
    
    @Environment(ToolState.self) private var toolState
    @State private var showColorPicker = false
    @State private var showBrushSize = false
    @State private var showShapePicker = false
    
    // Tool groups for the palette
    private let inkTools: [ToolType] = [.fountainPen, .pencil, .marker, .highlighter]
    private let utilityTools: [ToolType] = [.eraserStroke, .eraserPixel, .lasso]
    
    var body: some View {
        @Bindable var toolState = toolState
        
        HStack(spacing: 0) {
            // Ink Tools
            HStack(spacing: 2) {
                ForEach(inkTools) { (tool: ToolType) in
                    toolButton(tool)
                }
            }
            
            divider
            
            // Color Well
            colorButton
            
            divider
            
            // Brush Size
            brushSizeButton
            
            divider
            
            // Utility Tools
            HStack(spacing: 2) {
                ForEach(utilityTools) { (tool: ToolType) in
                    toolButton(tool)
                }
            }
            
            divider
            
            // Shapes Button
            Button {
                showShapePicker.toggle()
            } label: {
                Image(systemName: "square.on.circle")
                    .font(.system(size: 18))
                    .frame(width: 40, height: 40)
                    .foregroundColor(.secondary)
            }
            
            divider
            
            // Ruler Toggle
            rulerButton
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.12), radius: 16, y: 6)
                .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
        )
        .padding(.horizontal, 20)
        .popover(isPresented: $showColorPicker) {
            ColorPickerView()
                .frame(width: 280, height: 340)
                .presentationCompactAdaptation(.popover)
        }
        .popover(isPresented: $showBrushSize) {
            BrushSizeSlider()
                .frame(width: 240, height: 100)
                .presentationCompactAdaptation(.popover)
        }
        .popover(isPresented: $showShapePicker) {
            ShapePickerView(viewModel: viewModel)
                .frame(width: 320, height: 200)
                .presentationCompactAdaptation(.popover)
        }
    }
    
    // MARK: - Tool Button
    
    private func toolButton(_ tool: ToolType) -> some View {
        let isSelected = toolState.currentToolType == tool
        
        return Button {
            withAnimation(.easeInOut(duration: 0.15)) {
                toolState.selectTool(tool)
            }
        } label: {
            VStack(spacing: 3) {
                Image(systemName: tool.systemImage)
                    .font(.system(size: 18, weight: isSelected ? .bold : .regular))
                    .symbolRenderingMode(.hierarchical)
                    .frame(width: 40, height: 32)
                    .foregroundColor(isSelected ? .accentColor : .secondary)
                
                // Active indicator
                Capsule()
                    .fill(isSelected ? Color.accentColor : Color.clear)
                    .frame(width: 20, height: 3)
            }
        }
        .contentShape(Rectangle())
    }
    
    // MARK: - Color Button
    
    private var colorButton: some View {
        Button {
            showColorPicker.toggle()
        } label: {
            Circle()
                .fill(Color(hex: toolState.currentColorHex) ?? .black)
                .frame(width: 28, height: 28)
                .overlay(
                    Circle()
                        .strokeBorder(.primary.opacity(0.15), lineWidth: 1.5)
                )
                .shadow(color: (Color(hex: toolState.currentColorHex) ?? .black).opacity(0.3), radius: 3, y: 1)
                .padding(7)
        }
    }
    
    // MARK: - Brush Size Button
    
    private var brushSizeButton: some View {
        Button {
            showBrushSize.toggle()
        } label: {
            Circle()
                .fill(.primary)
                .frame(
                    width: max(6, min(20, toolState.currentLineWidth * 2)),
                    height: max(6, min(20, toolState.currentLineWidth * 2))
                )
                .frame(width: 40, height: 40)
        }
    }
    
    // MARK: - Ruler Button
    
    private var rulerButton: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.15)) {
                toolState.isRulerActive.toggle()
            }
        } label: {
            Image(systemName: "ruler")
                .font(.system(size: 18, weight: toolState.isRulerActive ? .bold : .regular))
                .frame(width: 40, height: 40)
                .foregroundColor(toolState.isRulerActive ? .accentColor : .secondary)
        }
    }
    
    // MARK: - Divider
    
    private var divider: some View {
        Rectangle()
            .fill(.separator)
            .frame(width: 1, height: 28)
            .padding(.horizontal, 5)
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.gray.opacity(0.1)
            .ignoresSafeArea()
        
        VStack {
            Spacer()
            ToolPaletteView()
                .padding(.bottom, 30)
        }
    }
    .environment(ToolState())
}
