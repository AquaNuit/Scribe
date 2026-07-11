// RulerOverlayView.swift
// Scribe — Transparent ruler overlay for drawing straight lines

import SwiftUI

struct RulerOverlayView: View {
    
    @Binding var isActive: Bool
    @State private var position: CGPoint = CGPoint(x: 400, y: 500)
    @State private var angle: Angle = .zero
    
    var body: some View {
        if isActive {
            GeometryReader { geometry in
                rulerBody
                    .position(position)
                    .rotationEffect(angle)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                position = value.location
                            }
                    )
                    .simultaneousGesture(
                        RotateGesture()
                            .onChanged { value in
                                angle = value.rotation
                            }
                    )
                    .onAppear {
                        position = CGPoint(
                            x: geometry.size.width / 2,
                            y: geometry.size.height / 2
                        )
                    }
            }
            .allowsHitTesting(true)
            .transition(.opacity)
        }
    }
    
    private var rulerBody: some View {
        ZStack {
            // Ruler background
            RoundedRectangle(cornerRadius: 4)
                .fill(.ultraThinMaterial.opacity(0.85))
                .frame(width: 500, height: 44)
            
            // Ruler markings
            HStack(spacing: 0) {
                ForEach(0..<50, id: \.self) { i in
                    VStack {
                        Rectangle()
                            .fill(.primary.opacity(0.3))
                            .frame(
                                width: 0.5,
                                height: i % 10 == 0 ? 16 : (i % 5 == 0 ? 10 : 6)
                            )
                        
                        if i % 10 == 0 {
                            Text("\(i / 10)")
                                .font(.system(size: 7))
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                    }
                    
                    if i < 49 {
                        Spacer()
                    }
                }
            }
            .padding(.horizontal, 4)
            .frame(width: 500, height: 44)
            
            // Edge guide (the drawing line)
            VStack {
                Spacer()
                Rectangle()
                    .fill(Color.accentColor.opacity(0.6))
                    .frame(width: 500, height: 1.5)
            }
            .frame(width: 500, height: 44)
            
            // Close button
            HStack {
                Spacer()
                Button {
                    withAnimation { isActive = false }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.trailing, 4)
            }
            .frame(width: 500)
        }
    }
}
