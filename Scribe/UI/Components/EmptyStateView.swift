// EmptyStateView.swift
// Scribe — Premium empty state placeholder with gradient accents

import SwiftUI

struct EmptyStateView: View {
    
    let icon: String
    let title: String
    let message: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil
    
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                ScribeTheme.accentColor.opacity(0.15),
                                ScribeTheme.accentColor.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                
                Image(systemName: icon)
                    .font(.system(size: 40))
                    .foregroundStyle(ScribeTheme.accentGradient)
                    .symbolRenderingMode(.hierarchical)
            }
            
            VStack(spacing: 6) {
                Text(title)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .fontDesign(.rounded)
                    .foregroundColor(.primary)
                
                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 280)
            }
            
            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    Text(actionTitle)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 10)
                        .background(ScribeTheme.accentGradient, in: Capsule())
                        .foregroundColor(.white)
                }
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
