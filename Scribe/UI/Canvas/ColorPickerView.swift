// ColorPickerView.swift
// Scribe — Custom color picker with swatches and recent colors

import SwiftUI

struct ColorPickerView: View {
    
    @Environment(ToolState.self) private var toolState
    
    private let swatches: [[String]] = [
        ["#000000", "#3A3A3A", "#636E72", "#B2BEC3", "#DFE6E9", "#FFFFFF"],
        ["#E74C3C", "#D63031", "#FF7675", "#FAB1A0", "#FDCB6E", "#FFEAA7"],
        ["#E67E22", "#F39C12", "#FF9F43", "#FFC048", "#00B894", "#55EFC4"],
        ["#2ECC71", "#27AE60", "#00CEC9", "#81ECEC", "#0984E3", "#74B9FF"],
        ["#3498DB", "#2980B9", "#5B7FFF", "#A29BFE", "#6C5CE7", "#D6A2E8"],
        ["#9B59B6", "#8E44AD", "#FF6B81", "#FF8ED4", "#FD79A8", "#E84393"],
    ]
    
    @State private var customColor = Color.black
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            Text("Color")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Swatch Grid
            VStack(spacing: 6) {
                ForEach(swatches.indices, id: \.self) { row in
                    HStack(spacing: 6) {
                        ForEach(swatches[row], id: \.self) { hex in
                            swatchButton(hex: hex)
                        }
                    }
                }
            }
            
            // Recent Colors
            if !toolState.recentColors.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Recent")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    HStack(spacing: 6) {
                        ForEach(toolState.recentColors.prefix(8), id: \.self) { hex in
                            swatchButton(hex: hex, size: 24)
                        }
                        Spacer()
                    }
                }
            }
            
            // System Color Picker
            HStack {
                ColorPicker("Custom", selection: $customColor)
                    .labelsHidden()
                    .onChange(of: customColor) { _, newValue in
                        toolState.selectColor(newValue.toHex())
                    }
                
                Text("Custom Color")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Spacer()
            }
        }
        .padding()
    }
    
    private func swatchButton(hex: String, size: CGFloat = 32) -> some View {
        let isSelected = toolState.currentColorHex.lowercased() == hex.lowercased()
        
        return Button {
            toolState.selectColor(hex)
        } label: {
            RoundedRectangle(cornerRadius: 6)
                .fill(Color(hex: hex) ?? .black)
                .frame(width: size, height: size)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .strokeBorder(
                            isSelected ? Color.accentColor : Color.primary.opacity(0.1),
                            lineWidth: isSelected ? 2.5 : 0.5
                        )
                )
                .scaleEffect(isSelected ? 1.1 : 1.0)
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.1), value: isSelected)
    }
}

// MARK: - Brush Size Slider

struct BrushSizeSlider: View {
    
    @Environment(ToolState.self) private var toolState
    
    var body: some View {
        @Bindable var toolState = toolState
        
        VStack(spacing: 12) {
            Text("Size: \(String(format: "%.1f", toolState.currentLineWidth))pt")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            HStack(spacing: 12) {
                // Small dot
                Circle()
                    .fill(.primary)
                    .frame(width: 4, height: 4)
                
                Slider(
                    value: $toolState.currentLineWidth,
                    in: 0.5...30,
                    step: 0.5
                )
                .tint(.accentColor)
                
                // Large dot
                Circle()
                    .fill(.primary)
                    .frame(width: 20, height: 20)
            }
            
            // Preview
            HStack {
                Spacer()
                Circle()
                    .fill(Color(hex: toolState.currentColorHex) ?? .black)
                    .frame(
                        width: max(4, toolState.currentLineWidth * 2),
                        height: max(4, toolState.currentLineWidth * 2)
                    )
                Spacer()
            }
        }
        .padding()
    }
}
