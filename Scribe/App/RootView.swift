// RootView.swift
// Scribe — Main root view with adaptive navigation

import SwiftUI
import SwiftData

struct RootView: View {
    
    @Environment(NavigationRouter.self) private var router
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    var body: some View {
        @Bindable var router = router
        
        NavigationSplitView(columnVisibility: $router.columnVisibility) {
            SidebarView()
                .navigationTitle("Scribe")
        } content: {
            ContentListView()
        } detail: {
            DetailContainerView()
        }
        .navigationSplitViewStyle(.balanced)
        .tint(ScribeTheme.accentColor)
        .onAppear {
            router.ensureDefaults()
        }
    }
}

#Preview {
    RootView()
        .environment(NavigationRouter())
        .environment(ToolState())
        .modelContainer(for: [Notebook.self, Section.self, Page.self, Tag.self], inMemory: true)
}
