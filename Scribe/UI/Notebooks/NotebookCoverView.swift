// NotebookCoverView.swift
// Scribe — Premium notebook cover card with depth effects and gradients

import SwiftUI

struct NotebookCoverView: View {
    
    let notebook: Notebook
    
    @State private var isHovered = false
    
    private var coverColor: Color {
        Color(hex: notebook.coverColorHex) ?? .blue
    }
    
    private var darkCoverColor: Color {
        Color(hex: notebook.coverColorHex)?.opacity(0.65) ?? .blue.opacity(0.65)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Cover
            ZStack {
                // Multi-layered gradient background
                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        LinearGradient(
                            colors: [
                                coverColor,
                                darkCoverColor
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                // Subtle noise/glass overlay
                RoundedRectangle(cornerRadius: 14)
                    .fill(.white.opacity(0.06))
                
                // Spine effect (left edge)
                HStack(spacing: 0) {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [.black.opacity(0.15), .clear],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: 12)
                    Spacer()
                }
                .clipShape(RoundedRectangle(cornerRadius: 14))
                
                // Content
                VStack(spacing: 10) {
                    Text(notebook.emoji ?? "📓")
                        .font(.system(size: 44))
                        .shadow(color: .black.opacity(0.2), radius: 4, y: 2)
                    
                    if notebook.pageCount > 0 {
                        Text("\(notebook.pageCount) pages")
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white.opacity(0.85))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(.white.opacity(0.18), in: Capsule())
                    }
                }
                
                // Favorite badge
                if notebook.isFavorite {
                    VStack {
                        HStack {
                            Spacer()
                            Image(systemName: "heart.fill")
                                .font(.caption)
                                .foregroundColor(.white)
                                .padding(6)
                                .background(.white.opacity(0.25), in: Circle())
                        }
                        Spacer()
                    }
                    .padding(10)
                }
                
                // Bottom shine
                VStack {
                    Spacer()
                    RoundedRectangle(cornerRadius: 14)
                        .fill(
                            LinearGradient(
                                colors: [.clear, .white.opacity(0.08)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(height: 40)
                }
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .frame(height: 190)
            
            // Info
            VStack(alignment: .leading, spacing: 3) {
                Text(notebook.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                    .foregroundColor(.primary)
                
                Text(notebook.modifiedAt.formatted(.relative(presentation: .named)))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 10)
        }
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.secondarySystemBackground))
        )
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .scribeCardShadow()
        .scaleEffect(isHovered ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isHovered)
        .onHover { hovering in
            isHovered = hovering
        }
        .contentShape(RoundedRectangle(cornerRadius: 14))
    }
}
