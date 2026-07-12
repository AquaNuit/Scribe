// ShapePickerView.swift
// Scribe — Shape insertion picker

import SwiftUI

struct ShapePickerView: View {
    
    @Environment(ToolState.self) private var toolState
    var viewModel: CanvasViewModel?
    @Environment(\.dismiss) private var dismiss
    
    let columns = [
        GridItem(.adaptive(minimum: 60, maximum: 80), spacing: 16)
    ]
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Insert Shape")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(ScribeShapeType.allCases) { shape in
                    Button {
                        insertShape(shape)
                        dismiss()
                    } label: {
                        VStack(spacing: 8) {
                            Image(systemName: shape.systemImage)
                                .font(.system(size: 24))
                                .foregroundColor(.accentColor)
                                .frame(width: 50, height: 50)
                                .background(Color.accentColor.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
                            
                            Text(shape.rawValue)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding()
    }
    
    private func insertShape(_ shape: ScribeShapeType) {
        guard let viewModel = viewModel else { return }
        
        let width = toolState.currentLineWidth
        // Insert shape in the middle of the current view (or some default location)
        let bounds = CGRect(x: 200, y: 200, width: 200, height: 200)
        
        viewModel.insertShape(
            shape,
            colorHex: toolState.currentColorHex,
            width: width,
            at: bounds
        )
    }
}
