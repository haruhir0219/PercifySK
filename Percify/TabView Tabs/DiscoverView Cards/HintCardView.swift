//
//  HintCardView.swift
//  Percify
//
//  Created by 松本知大 on 2026/01/13.
//

import SwiftUI
import GlowGetter

struct HintCardView: View {
    // Closures for swipe actions
    var onSwipe: (() -> Void)?
    
    // Circle slide animation state - separate for each slider
    @State private var likeCircleOffset: CGFloat = 0
    @State private var dislikeCircleOffset: CGFloat = 0
    @State private var likeAnimationTask: Task<Void, Never>?
    @State private var dislikeAnimationTask: Task<Void, Never>?
    
    // Drag state
    @State private var translation: CGSize = .zero
    @State private var isDragging: Bool = false
    @State private var lastTranslation: CGSize = .zero
    @State private var lastUpdateTime: Date = Date()
    
    // Haptic feedback generators
    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    private let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    
    // Thresholds
    private let swipeThreshold: CGFloat = 120
    private let velocityResistanceFactor: CGFloat = 0.3
    
    var body: some View {
        cardContent
            .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
            .frame(width: UIScreen.main.bounds.width * 0.928)
            .frame(height: UIScreen.main.bounds.height * 0.62)
            .rotationEffect(.degrees(Double(translation.width / 20)))
            .offset(x: translation.width, y: translation.height)
            .contentShape(Rectangle())
            .highPriorityGesture(dragGesture)
            .animation(.spring(response: 0.3, dampingFraction: 0.9), value: translation)
            .overlay {
                swipeOverlays
            }
    }
    
    // MARK: - Card Content
    
    private var cardContent: some View {
        ZStack {
            // Card background with same styling as RecruitmentCardView
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .strokeBorder(.ultraThinMaterial, lineWidth: 1.2)
                )
            
            // Content
            VStack(alignment: .center, spacing: 16) {
                Image("PercifySK")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                Text("Percify就活へ\nようこそ")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                
                // Animated sliders stacked on top of each other
                VStack(spacing: 32) {
                    // Like slider (right direction)
                    likeSlider
                    
                    // Dislike slider (left direction)
                    dislikeSlider
                }
                .padding(.top, 24)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
    }
    
    // MARK: - Swipe Overlays
    
    private var swipeOverlays: some View {
        ZStack {
            // Like overlay (right swipe)
            if translation.width > 50 {
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [.green.opacity(0.6), .clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .overlay(alignment: .leading) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.white)
                            .padding(40)
                    }
                    .opacity(Double(translation.width / swipeThreshold))
            }
            
            // Dislike overlay (left swipe)
            if translation.width < -50 {
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [.clear, .orange.opacity(0.6)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .overlay(alignment: .trailing) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.white)
                            .padding(40)
                    }
                    .opacity(Double(-translation.width / swipeThreshold))
            }
        }
        .allowsHitTesting(false)
    }
    
    // MARK: - Drag Gesture
    
    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                handleDragChanged(value)
            }
            .onEnded { value in
                handleDragEnded(value)
            }
    }
    
    private func handleDragChanged(_ value: DragGesture.Value) {
        if !isDragging {
            isDragging = true
            lastTranslation = .zero
            lastUpdateTime = Date()
            impactLight.prepare()
            impactLight.impactOccurred(intensity: 0.6)
        }
        
        // Calculate velocity
        let currentTime = Date()
        let timeDelta = currentTime.timeIntervalSince(lastUpdateTime)
        
        if timeDelta > 0 {
            let deltaX = value.translation.width - lastTranslation.width
            let velocityX = abs(deltaX / timeDelta)
            
            // Apply resistance based on velocity
            let resistanceFactor = 1.0 / (1.0 + velocityResistanceFactor * velocityX / 1000.0)
            
            let resistedWidth = lastTranslation.width + (value.translation.width - lastTranslation.width) * resistanceFactor
            let resistedHeight = lastTranslation.height + (value.translation.height - lastTranslation.height) * resistanceFactor
            
            translation = CGSize(width: resistedWidth, height: resistedHeight)
            
            lastTranslation = translation
            lastUpdateTime = currentTime
        } else {
            translation = value.translation
        }
    }
    
    private func handleDragEnded(_ value: DragGesture.Value) {
        let shouldSwipe = abs(translation.width) > swipeThreshold
        
        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
            if shouldSwipe {
                // Swipe off screen
                translation = CGSize(
                    width: translation.width > 0 ? 1000 : -1000,
                    height: translation.height
                )
            } else {
                // Return to center
                translation = .zero
            }
        }
        
        if shouldSwipe {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                onSwipe?()
                isDragging = false
                lastTranslation = .zero
            }
        } else {
            isDragging = false
            lastTranslation = .zero
        }
    }
    
    // MARK: - Like Slider (Right Direction)
    
    private var likeSlider: some View {
        VStack(alignment: .center, spacing: 8) {
            // Isolated container for the circle animation
            GeometryReader { geometry in
                ZStack {
                    Capsule()
                        .fill(.ultraThinMaterial)
                        .frame(width: 160, height: 40)
                        .overlay(
                            RoundedRectangle(cornerRadius: 32, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [.clear, .white.opacity(0.7)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 32, style: .continuous)
                                .strokeBorder(Color.white.opacity(0.45), lineWidth: 1.2)
                        )
                    
                    Circle()
                        .fill(Color.white)
                        .clipShape(Circle())
                        .glow(0.8, Circle())
                        .frame(width: 36, height: 36)
                        .overlay(
                            Image(systemName: "arrow.right")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.clear)
                        )
                        .offset(x: likeCircleOffset)
                        .id("likeCircle") // Unique ID to isolate animation state
                }
                .frame(width: 160, height: 40)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
            .frame(width: 160, height: 40)
            .onAppear {
                startLikeCircleAnimation()
            }
            .onDisappear {
                likeAnimationTask?.cancel()
            }
            
            VStack(alignment: .center, spacing: 4) {
                Text("右にフリックしてお気に入り")
                    .font(.headline)
                    .foregroundColor(.primary)
            }
        }
    }
    
    // MARK: - Dislike Slider (Left Direction)
    
    private var dislikeSlider: some View {
        VStack(alignment: .center, spacing: 8) {
            // Isolated container for the circle animation
            VStack(alignment: .center, spacing: 4) {
                Text("左にフリックしてスキップ")
                    .font(.headline)
                    .foregroundColor(.primary)
            }
            GeometryReader { geometry in
                ZStack {
                    Capsule()
                        .fill(.ultraThinMaterial)
                        .frame(width: 160, height: 40)
                        .overlay(
                            RoundedRectangle(cornerRadius: 32, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [.clear, .white.opacity(0.7)],
                                        startPoint: .trailing,
                                        endPoint: .leading
                                    )
                                )
                                .strokeBorder(Color.white.opacity(0.45), lineWidth: 1.2)
                        )
                    
                    Circle()
                        .fill(Color.white)
                        .clipShape(Circle())
                        .glow(0.8, Circle())
                        .frame(width: 36, height: 36)
                        .overlay(
                            Image(systemName: "arrow.left")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.clear)
                        )
                        .offset(x: dislikeCircleOffset)
                        .id("dislikeCircle") // Unique ID to isolate animation state
                }
                .frame(width: 160, height: 40)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
            .frame(width: 160, height: 40)
            .onAppear {
                startDislikeCircleAnimation()
            }
            .onDisappear {
                dislikeAnimationTask?.cancel()
            }
        }
    }
    
    // MARK: - Helper Functions
    
    private func startLikeCircleAnimation() {
        // Cancel any existing animation task
        likeAnimationTask?.cancel()
        
        // Calculate the distance the circle can travel
        // Capsule width is 160, circle diameter is 36
        // Maximum offset = (160 - 36) / 2 = 62
        let maxOffset: CGFloat = 62
        
        // Like animation goes from left to right
        let startPosition: CGFloat = -maxOffset
        let endPosition: CGFloat = maxOffset
        
        // Start position immediately without animation to prevent glitches
        likeCircleOffset = startPosition
        
        // Create a new animation task
        likeAnimationTask = Task { @MainActor in
            // Small delay to ensure the view is ready
            try? await Task.sleep(nanoseconds: 50_000_000) // 0.05 seconds
            
            guard !Task.isCancelled else { return }
            
            // Animate to end position with easeInOut
            withAnimation(.easeInOut(duration: 1.0)) {
                likeCircleOffset = endPosition
            }
            
            // Wait for animation to complete
            try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
            
            guard !Task.isCancelled else { return }
            
            // Spring back to start with constrained animation
            withAnimation(.spring(response: 0.8, dampingFraction: 0.75)) {
                likeCircleOffset = startPosition
            }
            
            // Wait before next cycle
            try? await Task.sleep(nanoseconds: 800_000_000) // 0.8 seconds
            
            guard !Task.isCancelled else { return }
            
            // Repeat the cycle
            startLikeCircleAnimation()
        }
    }
    
    private func startDislikeCircleAnimation() {
        // Cancel any existing animation task
        dislikeAnimationTask?.cancel()
        
        // Calculate the distance the circle can travel
        // Capsule width is 160, circle diameter is 36
        // Maximum offset = (160 - 36) / 2 = 62
        let maxOffset: CGFloat = 62
        
        // Dislike animation goes from right to left (reversed)
        let startPosition: CGFloat = maxOffset
        let endPosition: CGFloat = -maxOffset
        
        // Start position immediately without animation to prevent glitches
        dislikeCircleOffset = startPosition
        
        // Create a new animation task
        dislikeAnimationTask = Task { @MainActor in
            // Small delay to ensure the view is ready
            try? await Task.sleep(nanoseconds: 50_000_000) // 0.05 seconds
            
            guard !Task.isCancelled else { return }
            
            // Animate to end position with easeInOut
            withAnimation(.easeInOut(duration: 1.0)) {
                dislikeCircleOffset = endPosition
            }
            
            // Wait for animation to complete
            try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
            
            guard !Task.isCancelled else { return }
            
            // Spring back to start with constrained animation
            withAnimation(.spring(response: 0.8, dampingFraction: 0.75)) {
                dislikeCircleOffset = startPosition
            }
            
            // Wait before next cycle
            try? await Task.sleep(nanoseconds: 800_000_000) // 0.8 seconds
            
            guard !Task.isCancelled else { return }
            
            // Repeat the cycle
            startDislikeCircleAnimation()
        }
    }
}

#Preview {
    HintCardView()
}
