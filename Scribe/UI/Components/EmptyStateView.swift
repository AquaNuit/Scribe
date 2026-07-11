// EmptyStateView.swift
// Scribe — Reusable empty state placeholder

import SwiftUI

struct EmptyStateView: View {
    
    let icon: String
    let title: String
    let message: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 52))
                .foregroundStyle(.tertiary)
                .symbolRenderingMode(.hierarchical)
            
            Text(title)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
            
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 280)
            
            if let actionTitle = actionTitle, let action = action {
                Button(actionTitle, action: action)
                    .buttonStyle(.borderedProminent)
                    .controlSize(.regular)
                    .padding(.top, 4)
            }
        }
    }
}

#Preview {
    EmptyStateView(
        icon: "book.closed",
        title: "No Notebooks",
        message: "Create your first notebook to get started",
        actionTitle: "Create Notebook"
    ) {
        print("Create")
    }
}
