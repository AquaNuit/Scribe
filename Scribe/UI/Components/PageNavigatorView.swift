// PageNavigatorView.swift
// Scribe — Horizontal page strip for quick navigation within a notebook

import SwiftUI
import SwiftData

struct PageNavigatorView: View {
    
    let section: Section
    @Binding var selectedPage: Page?
    var onPageSelected: ((Page) -> Void)? = nil
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 12) {
                ForEach(section.sortedPages) { page in
                    pageCell(page)
                        .onTapGesture {
                            selectedPage = page
                            onPageSelected?(page)
                        }
                }
            }
            .padding(.horizontal, 16)
        }
        .frame(height: 100)
        .background(.ultraThinMaterial)
    }
    
    private func pageCell(_ page: Page) -> some View {
        let isSelected = selectedPage?.id == page.id
        
        return VStack(spacing: 4) {
            // Thumbnail
            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color(.systemBackground))
                    .frame(width: 56, height: 72)
                
                if let thumbnailData = page.thumbnailData,
                   let uiImage = UIImage(data: thumbnailData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 56, height: 72)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                } else {
                    Image(systemName: page.backgroundStyle.systemImage)
                        .font(.caption2)
                        .foregroundStyle(.quaternary)
                }
            }
            .overlay(
                isSelected
                ? RoundedRectangle(cornerRadius: 6)
                    .strokeBorder(Color.accentColor, lineWidth: 2)
                : nil
            )
            .shadow(color: isSelected ? Color.accentColor.opacity(0.3) : .clear, radius: 4)
            
            // Page number
            Text("\(page.sortOrder + 1)")
                .font(.system(size: 10))
                .foregroundStyle(isSelected ? .primary : .secondary)
        }
    }
}
