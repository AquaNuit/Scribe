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
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                ScribeTheme.accentColor.opacity(0.12),
                                ScribeTheme.accentColor.opacity(0.04)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                
                Image(systemName: "pencil.and.scribble")
                    .font(.system(size: 48))
                    .foregroundStyle(ScribeTheme.accentGradient)
                    .symbolRenderingMode(.hierarchical)
            }
            
            VStack(spacing: 6) {
                Text("Select a Notebook")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .fontDesign(.rounded)
                    .foregroundColor(.primary)
                
                Text("Choose a notebook from the list or create a new one")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
