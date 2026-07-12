// NotebookCoverView.swift
// Scribe — Beautiful notebook cover card for the browser grid

import SwiftUI

struct NotebookCoverView: View {
    
    let notebook: Notebook
    
    private var coverColor: Color {
        Color(hex: notebook.coverColorHex) ?? .blue
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Cover
            ZStack {
                // Background gradient
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [
                                coverColor,
                                coverColor.opacity(0.7)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                // Subtle pattern overlay
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial.opacity(0.1))
                
                // Emoji
                VStack(spacing: 8) {
                    Text(notebook.emoji ?? "📓")
                        .font(.system(size: 48))
                    
                    if notebook.pageCount > 0 {
                        Text("\(notebook.pageCount) pages")
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundStyle(.white.opacity(0.8))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(.white.opacity(0.2), in: Capsule())
                    }
                }
                
                // Favorite badge
                if notebook.isFavorite {
                    VStack {
                        HStack {
                            Spacer()
                            Image(systemName: "heart.fill")
                                .font(.caption)
                                .foregroundStyle(.white)
                                .padding(6)
                                .background(.white.opacity(0.25), in: Circle())
                        }
                        Spacer()
                    }
                    .padding(10)
                }
            }
            .frame(height: 180)
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(notebook.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                    .foregroundStyle(.primary)
                
                Text(notebook.modifiedAt.formatted(.relative(presentation: .named)))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 10)
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.background)
                .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
        )
        .contentShape(RoundedRectangle(cornerRadius: 16))
    }
}
