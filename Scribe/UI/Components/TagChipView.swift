// TagChipView.swift
// Scribe — Compact tag badge for display and selection

import SwiftUI

struct TagChipView: View {
    
    let tag: Tag
    var isSelected: Bool = false
    var onTap: (() -> Void)? = nil
    var onRemove: (() -> Void)? = nil
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(Color(hex: tag.colorHex) ?? .accentColor)
                .frame(width: 8, height: 8)
            
            Text(tag.name)
                .font(.caption)
                .fontWeight(.medium)
                .lineLimit(1)
            
            if onRemove != nil {
                Button {
                    onRemove?()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(
            Capsule()
                .fill(isSelected
                      ? (Color(hex: tag.colorHex) ?? .accentColor).opacity(0.2)
                      : Color(.systemGray6))
        )
        .overlay(
            isSelected
            ? Capsule().strokeBorder(Color(hex: tag.colorHex) ?? .accentColor, lineWidth: 1.5)
            : nil
        )
        .contentShape(Capsule())
        .onTapGesture {
            onTap?()
        }
    }
}

// MARK: - Tag Flow Layout

struct TagFlowView: View {
    
    let tags: [Tag]
    var onTagTap: ((Tag) -> Void)? = nil
    var onTagRemove: ((Tag) -> Void)? = nil
    
    var body: some View {
        FlowLayout(spacing: 6) {
            ForEach(tags) { tag in
                TagChipView(
                    tag: tag,
                    onTap: { onTagTap?(tag) },
                    onRemove: onTagRemove != nil ? { onTagRemove?(tag) } : nil
                )
            }
        }
    }
}

// MARK: - Simple Flow Layout

struct FlowLayout: Layout {
    
    var spacing: CGFloat = 6
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = calculateLayout(subviews: subviews, maxWidth: proposal.width ?? .infinity)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = calculateLayout(subviews: subviews, maxWidth: bounds.width)
        
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y),
                proposal: ProposedViewSize(subviews[index].sizeThatFits(.unspecified))
            )
        }
    }
    
    private struct LayoutResult {
        var positions: [CGPoint]
        var size: CGSize
    }
    
    private func calculateLayout(subviews: Subviews, maxWidth: CGFloat) -> LayoutResult {
        var positions: [CGPoint] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        var maxX: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            
            if currentX + size.width > maxWidth && currentX > 0 {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }
            
            positions.append(CGPoint(x: currentX, y: currentY))
            lineHeight = max(lineHeight, size.height)
            currentX += size.width + spacing
            maxX = max(maxX, currentX - spacing)
        }
        
        return LayoutResult(
            positions: positions,
            size: CGSize(width: maxX, height: currentY + lineHeight)
        )
    }
}

#Preview {
    let tags = [
        Tag(name: "Physics", colorHex: "#3498DB"),
        Tag(name: "Important", colorHex: "#E74C3C"),
        Tag(name: "Review", colorHex: "#2ECC71"),
        Tag(name: "Math", colorHex: "#F39C12"),
    ]
    
    return VStack {
        TagFlowView(tags: tags)
    }
    .padding()
}
