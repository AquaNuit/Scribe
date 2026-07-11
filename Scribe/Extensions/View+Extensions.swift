// View+Extensions.swift
// Scribe — SwiftUI view modifier extensions

import SwiftUI

extension View {
    
    /// Apply a conditional modifier
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
    
    /// Apply a card style with shadow
    func cardStyle(cornerRadius: CGFloat = 16) -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.background)
                    .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
    
    /// Apply glass morphism effect
    func glassMorphism(cornerRadius: CGFloat = 16) -> some View {
        self
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius))
            .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
    }
}
