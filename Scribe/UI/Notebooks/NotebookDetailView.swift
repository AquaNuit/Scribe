// NotebookDetailView.swift
// Scribe — Notebook detail showing sections and pages

import SwiftUI
import SwiftData

struct NotebookDetailView: View {
    
    @Environment(NavigationRouter.self) private var router
    @Environment(\.modelContext) private var modelContext
    
    let notebook: Notebook
    @State private var showAddPage = false
    @State private var showAddSection = false
    @State private var newSectionTitle = ""
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 24) {
                // Header
                notebookHeader
                
                // Sections
                ForEach(notebook.sortedSections) { section in
                    sectionView(section)
                }
            }
            .padding()
        }
        .navigationTitle(notebook.title)
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Menu {
                    Button {
                        addPageToFirstSection()
                    } label: {
                        Label("New Page", systemImage: "doc.badge.plus")
                    }
                    
                    Button {
                        showAddSection = true
                    } label: {
                        Label("New Section", systemImage: "folder.badge.plus")
                    }
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .alert("New Section", isPresented: $showAddSection) {
            TextField("Section Title", text: $newSectionTitle)
            Button("Cancel", role: .cancel) { newSectionTitle = "" }
            Button("Create") {
                createSection()
            }
        } message: {
            Text("Enter a name for the new section")
        }
    }
    
    // MARK: - Header
    
    private var notebookHeader: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color(hex: notebook.coverColorHex) ?? .blue)
                    .frame(width: 56, height: 56)
                
                Text(notebook.emoji ?? "📓")
                    .font(.title2)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(notebook.title)
                    .font(.title2)
                    .fontWeight(.bold)
                
                HStack(spacing: 12) {
                    Label("\(notebook.pageCount) pages", systemImage: "doc")
                    Label("\(notebook.sortedSections.count) sections", systemImage: "folder")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .padding(.bottom, 8)
    }
    
    // MARK: - Section View
    
    @ViewBuilder
    private func sectionView(_ section: Section) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(section.title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                Spacer()
                
                Text("\(section.sortedPages.count)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(.fill, in: Capsule())
            }
            
            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 140, maximum: 180), spacing: 12)],
                spacing: 12
            ) {
                ForEach(section.sortedPages) { page in
                    pageCard(page)
                        .onTapGesture {
                            router.navigateToPage(page, in: notebook)
                        }
                        .contextMenu {
                            pageContextMenu(page, section: section)
                        }
                }
                
                // Add page button
                addPageButton(section: section)
            }
        }
    }
    
    // MARK: - Page Card
    
    private func pageCard(_ page: Page) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // Thumbnail
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .strokeBorder(Color(.separator), lineWidth: 0.5)
                    )
                
                if let thumbnailData = page.thumbnailData,
                   let uiImage = UIImage(data: thumbnailData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                } else {
                    VStack(spacing: 6) {
                        Image(systemName: page.backgroundStyle.systemImage)
                            .font(.title3)
                            .foregroundStyle(.quaternary)
                        
                        Text(page.backgroundStyle.displayName)
                            .font(.caption2)
                            .foregroundStyle(.quaternary)
                    }
                }
            }
            .frame(height: 160)
            
            // Title
            Text(page.title.isEmpty ? "Untitled" : page.title)
                .font(.caption)
                .foregroundStyle(page.title.isEmpty ? .tertiary : .primary)
                .lineLimit(1)
                .padding(.top, 6)
        }
    }
    
    // MARK: - Add Page Button
    
    private func addPageButton(section: Section) -> some View {
        Button {
            let service = PageService(modelContext: modelContext)
            let page = service.createPage(in: section)
            router.navigateToPage(page, in: notebook)
        } label: {
            VStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(style: StrokeStyle(lineWidth: 1.5, dash: [6, 4]))
                        .foregroundStyle(.tertiary)
                    
                    Image(systemName: "plus")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                }
                .frame(height: 160)
                
                Text("New Page")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.top, 6)
            }
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Context Menu
    
    @ViewBuilder
    private func pageContextMenu(_ page: Page, section: Section) -> some View {
        Button {
            let service = PageService(modelContext: modelContext)
            service.duplicatePage(page)
        } label: {
            Label("Duplicate", systemImage: "doc.on.doc")
        }
        
        Divider()
        
        Button(role: .destructive) {
            let service = PageService(modelContext: modelContext)
            service.deletePage(page)
        } label: {
            Label("Delete", systemImage: "trash")
        }
    }
    
    // MARK: - Actions
    
    private func addPageToFirstSection() {
        guard let section = notebook.sortedSections.first else {
            // Create a section first
            createSection()
            return
        }
        let service = PageService(modelContext: modelContext)
        let page = service.createPage(in: section)
        router.navigateToPage(page, in: notebook)
    }
    
    private func createSection() {
        let title = newSectionTitle.isEmpty ? "Section \(notebook.sortedSections.count + 1)" : newSectionTitle
        let service = SectionService(modelContext: modelContext)
        service.createSection(in: notebook, title: title)
        newSectionTitle = ""
    }
}
