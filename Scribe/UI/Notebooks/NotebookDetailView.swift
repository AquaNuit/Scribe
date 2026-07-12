// NotebookDetailView.swift
// Scribe — Notebook detail showing sections and pages with premium design

import SwiftUI
import SwiftData

struct NotebookDetailView: View {
    
    @Environment(NavigationRouter.self) private var router
    @Environment(\.modelContext) private var modelContext
    
    let notebook: Notebook
    @State private var showAddSection = false
    @State private var newSectionTitle = ""
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 28) {
                notebookHeader
                
                ForEach(notebook.sortedSections) { (section: Section) in
                    sectionView(section)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
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
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: notebook.coverColorHex) ?? .blue,
                                (Color(hex: notebook.coverColorHex) ?? .blue).opacity(0.7)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 56, height: 56)
                
                Text(notebook.emoji ?? "📓")
                    .font(.title2)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(notebook.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .fontDesign(.rounded)
                
                HStack(spacing: 12) {
                    Label("\(notebook.pageCount) pages", systemImage: "doc")
                    Label("\(notebook.sortedSections.count) sections", systemImage: "folder")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.bottom, 4)
    }
    
    // MARK: - Section View
    
    @ViewBuilder
    private func sectionView(_ section: Section) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text(section.title)
                    .font(.headline)
                    .fontDesign(.rounded)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(section.sortedPages.count)")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color(.tertiarySystemFill), in: Capsule())
            }
            
            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 150, maximum: 190), spacing: 16)],
                spacing: 16
            ) {
                ForEach(section.sortedPages) { (page: Page) in
                    pageCard(page)
                        .onTapGesture {
                            router.navigateToPage(page, in: notebook)
                        }
                        .contextMenu {
                            pageContextMenu(page, section: section)
                        }
                }
                
                addPageButton(section: section)
            }
        }
    }
    
    // MARK: - Page Card
    
    private func pageCard(_ page: Page) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(.secondarySystemBackground))
                
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(Color(.separator).opacity(0.5), lineWidth: 0.5)
                
                if let thumbnailData = page.thumbnailData,
                   let uiImage = UIImage(data: thumbnailData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                } else {
                    VStack(spacing: 8) {
                        Image(systemName: page.backgroundStyle.systemImage)
                            .font(.title2)
                            .foregroundColor(.tertiary)
                        
                        Text(page.backgroundStyle.displayName)
                            .font(.caption2)
                            .foregroundColor(.quaternary)
                    }
                }
            }
            .frame(height: 170)
            
            Text(page.title.isEmpty ? "Untitled" : page.title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(page.title.isEmpty ? .tertiary : .primary)
                .lineLimit(1)
                .padding(.top, 8)
        }
        .scribeCardShadow()
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
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(style: StrokeStyle(lineWidth: 1.5, dash: [6, 4]))
                        .foregroundColor(.tertiary)
                    
                    VStack(spacing: 6) {
                        Image(systemName: "plus")
                            .font(.title2)
                            .foregroundColor(.secondary)
                        
                        Text("New Page")
                            .font(.caption2)
                            .foregroundColor(.tertiary)
                    }
                }
                .frame(height: 170)
                
                Text(" ")
                    .font(.caption)
                    .padding(.top, 8)
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
