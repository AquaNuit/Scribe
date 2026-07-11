// ContentListView.swift
// Scribe — Content list showing notebooks or pages based on sidebar selection

import SwiftUI
import SwiftData

struct ContentListView: View {
    
    @Environment(NavigationRouter.self) private var router
    @Environment(\.modelContext) private var modelContext
    
    @Query(
        filter: #Predicate<Notebook> { !$0.isArchived },
        sort: \Notebook.modifiedAt,
        order: .reverse
    )
    private var notebooks: [Notebook]
    
    @Query(
        filter: #Predicate<Notebook> { $0.isFavorite && !$0.isArchived },
        sort: \Notebook.modifiedAt,
        order: .reverse
    )
    private var favorites: [Notebook]
    
    @Query(
        filter: #Predicate<Notebook> { $0.isArchived },
        sort: \Notebook.modifiedAt,
        order: .reverse
    )
    private var archived: [Notebook]
    
    var body: some View {
        @Bindable var router = router
        
        Group {
            switch router.selectedSidebarItem {
            case .allNotebooks:
                notebookGrid(notebooks, title: "All Notebooks")
            case .favorites:
                notebookGrid(favorites, title: "Favorites")
            case .recentlyModified:
                notebookGrid(Array(notebooks.prefix(20)), title: "Recent")
            case .archive:
                notebookGrid(archived, title: "Archive")
            case .tags, .trash:
                notebookGrid(notebooks, title: "Notebooks")
            case .none:
                EmptyView()
            }
        }
        .searchable(text: $router.searchQuery, prompt: "Search notebooks")
    }
    
    // MARK: - Notebook Grid
    
    @ViewBuilder
    private func notebookGrid(_ items: [Notebook], title: String) -> some View {
        let filtered = router.searchQuery.isEmpty
            ? items
            : items.filter { $0.title.localizedCaseInsensitiveContains(router.searchQuery) }
        
        ScrollView {
            if filtered.isEmpty {
                EmptyStateView(
                    icon: "book.closed",
                    title: "No Notebooks",
                    message: "Tap + to create your first notebook"
                )
                .frame(maxWidth: .infinity, minHeight: 400)
            } else {
                LazyVGrid(
                    columns: [GridItem(.adaptive(minimum: 180, maximum: 220), spacing: 20)],
                    spacing: 20
                ) {
                    ForEach(filtered) { notebook in
                        NotebookCoverView(notebook: notebook)
                            .onTapGesture {
                                router.navigateToNotebook(notebook)
                            }
                            .contextMenu {
                                notebookContextMenu(notebook)
                            }
                    }
                }
                .padding()
            }
        }
        .navigationTitle(title)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    router.showCreateNotebook = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
    }
    
    // MARK: - Context Menu
    
    @ViewBuilder
    private func notebookContextMenu(_ notebook: Notebook) -> some View {
        Button {
            let service = NotebookService(modelContext: modelContext)
            service.toggleFavorite(notebook)
        } label: {
            Label(
                notebook.isFavorite ? "Remove from Favorites" : "Add to Favorites",
                systemImage: notebook.isFavorite ? "heart.slash" : "heart"
            )
        }
        
        Divider()
        
        Button {
            // Duplicate
            let service = NotebookService(modelContext: modelContext)
            let _ = service.createNotebook(
                title: "\(notebook.title) (Copy)",
                coverColor: notebook.coverColorHex,
                emoji: notebook.emoji
            )
        } label: {
            Label("Duplicate", systemImage: "doc.on.doc")
        }
        
        Button {
            let service = NotebookService(modelContext: modelContext)
            service.archiveNotebook(notebook)
        } label: {
            Label("Archive", systemImage: "archivebox")
        }
        
        Divider()
        
        Button(role: .destructive) {
            let service = NotebookService(modelContext: modelContext)
            service.deleteNotebook(notebook)
        } label: {
            Label("Delete", systemImage: "trash")
        }
    }
}
