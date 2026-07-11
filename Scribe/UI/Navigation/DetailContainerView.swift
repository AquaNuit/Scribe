// DetailContainerView.swift
// Scribe — Detail panel showing notebook contents or canvas editor

import SwiftUI
import SwiftData

struct DetailContainerView: View {
    
    @Environment(NavigationRouter.self) private var router
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        Group {
            if let notebook = router.selectedNotebook {
                NotebookDetailView(notebook: notebook)
            } else {
                emptyDetail
            }
        }
        .fullScreenCover(isPresented: Binding(
            get: { router.isCanvasPresented },
            set: { router.isCanvasPresented = $0 }
        )) {
            if let page = router.selectedPage {
                CanvasEditorView(page: page)
            }
        }
    }
    
    private var emptyDetail: some View {
        VStack(spacing: 16) {
            Image(systemName: "pencil.and.scribble")
                .font(.system(size: 64))
                .foregroundStyle(.tertiary)
            
            Text("Select a Notebook")
                .font(.title2)
                .foregroundStyle(.secondary)
            
            Text("Choose a notebook from the list or create a new one")
                .font(.subheadline)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
