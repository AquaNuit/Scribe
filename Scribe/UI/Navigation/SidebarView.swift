// SidebarView.swift
// Scribe — Main sidebar navigation

import SwiftUI
import SwiftData

struct SidebarView: View {
    
    @Environment(NavigationRouter.self) private var router
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<Tag> { _ in true }, sort: \Tag.name)
    private var tags: [Tag]
    
    var body: some View {
        @Bindable var router = router
        
        List(selection: $router.selectedSidebarItem) {
            // MARK: - Main
            
            SwiftUI.Section("Library") {
                Label("All Notebooks", systemImage: "books.vertical")
                    .tag(NavigationRouter.SidebarItem.allNotebooks)
                
                Label("Favorites", systemImage: "heart.fill")
                    .tag(NavigationRouter.SidebarItem.favorites)
                
                Label("Recent", systemImage: "clock")
                    .tag(NavigationRouter.SidebarItem.recentlyModified)
            }
            
            // MARK: - Tags
            
            if !tags.isEmpty {
                SwiftUI.Section("Tags") {
                    Label("All Tags", systemImage: "tag")
                        .tag(NavigationRouter.SidebarItem.tags)
                    
                    ForEach(tags) { tag in
                        Label(tag.name, systemImage: "tag.fill")
                            .foregroundStyle(Color(hex: tag.colorHex) ?? .accentColor)
                    }
                }
            }
            
            // MARK: - Archive
            
            SwiftUI.Section {
                Label("Archive", systemImage: "archivebox")
                    .tag(NavigationRouter.SidebarItem.archive)
            }
        }
        .listStyle(.sidebar)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    router.showCreateNotebook = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                }
                .accessibilityLabel("Create Notebook")
            }
            
            ToolbarItem(placement: .bottomBar) {
                Button {
                    router.showSettings = true
                } label: {
                    Label("Settings", systemImage: "gearshape")
                }
            }
        }
        .sheet(isPresented: $router.showSettings) {
            SettingsView()
        }
        .sheet(isPresented: $router.showCreateNotebook) {
            CreateNotebookSheet()
        }
    }
}
