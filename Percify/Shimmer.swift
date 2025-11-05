// Shimmer.swift
// Shared shimmer modifier for loading effects
import SwiftUI

public struct Shimmer: ViewModifier {
    @State private var xOffset: CGFloat = 0
    public func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geo in
                    let shimmerWidth = geo.size.width * 2.5
                    let startOffset = -shimmerWidth
                    let endOffset = geo.size.width
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.0),
                            Color.white.opacity(0.3),
                            Color.white.opacity(0.6),
                            Color.white.opacity(0.9),
                            Color.white.opacity(0.6),
                            Color.white.opacity(0.3),
                            Color.white.opacity(0.0)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: shimmerWidth, height: geo.size.height)
                    .offset(x: xOffset)
                    .onAppear {
                        xOffset = startOffset
                        withAnimation(Animation.linear(duration: 1.4).repeatForever(autoreverses: false)) {
                            xOffset = endOffset
                        }
                    }
                    .onDisappear {
                        xOffset = startOffset
                    }
                }
                .allowsHitTesting(false)
            )
    }
}

public extension View {
    func shimmering() -> some View {
        self.modifier(Shimmer())
    }
}
