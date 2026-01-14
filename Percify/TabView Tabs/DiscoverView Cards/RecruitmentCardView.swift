import SwiftUI
import Charts
import GlowGetter

// MARK: - Visibility Preference Key

struct VisibilityPreferenceKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}

struct Recruitment: Identifiable, Equatable {
    let id = UUID()
    let companyName: String
    let companyLogo: String
    let badgeText: String
    let titleText: String
    let industryLeft: String
    let industryRight: String
    let typeLeft: String
    let typeRight: String
    let pay1Label: String
    let pay1Value: String
    let pay2Label: String
    let pay2Value: String
    let tag1: String
    let tag2: String
    let tag3: String
    let deadline: String
    let classification: String
    let headerImageURL: URL
    let location: String
}

struct RecruitmentCardView: View {
    let recruitment: Recruitment
    let onLike: (Recruitment) -> Void
    let onDislike: (Recruitment) -> Void

    @State private var showDetails: Bool = false
    @Namespace var transition

    // Drag state
    @State private var translation: CGSize = .zero
    @State private var isDragging: Bool = false
    @State private var lastTranslation: CGSize = .zero
    @State private var lastUpdateTime: Date = Date()
    
    // Chart animation state
    @State private var chartData: [Double] = []
    @State private var animateChart: Bool = false
    @State private var isChartVisible: Bool = false
    
    // Shake animation state
    @State private var shakeOffset: CGFloat = 0
    
    // Image fade animation state
    @State private var imageOpacity: Double = 0
    
    // Circle slide animation state
    @State private var circleOffset: CGFloat = 0
    @State private var circleAnimationTask: Task<Void, Never>?

    // Haptic feedback generators
    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    private let impactMedium = UIImpactFeedbackGenerator(style: .medium)

    // Thresholds
    private let swipeThreshold: CGFloat = 120
    private let velocityResistanceFactor: CGFloat = 0.3 // Lower = more resistance

    var body: some View {
        cardContent
            .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
            .matchedTransitionSource(id: "card", in: transition)
            .frame(width: UIScreen.main.bounds.width * 0.928)
            .frame(height: UIScreen.main.bounds.height * 0.62)
            .rotationEffect(.degrees(Double(translation.width / 20)))
            .offset(x: translation.width, y: translation.height)
            .contentShape(Rectangle())
            .onTapGesture {
                showDetails = true
            }
            .highPriorityGesture(dragGesture)
            .animation(.spring(response: 0.3, dampingFraction: 0.9), value: translation)
            .fullScreenCover(isPresented: $showDetails) {
                RecruitmentDetailsView(
                    jobID: recruitment.id.uuidString,
                    imageURL: recruitment.headerImageURL,
                    eikenRequired: "2級以上",
                    toeicRequired: "600点以上",
                    companyLogo: recruitment.companyLogo,
                    title: recruitment.titleText,
                    businessName: recruitment.companyName,
                    stationName: recruitment.location,
                    jobDuration: "3ヶ月〜長期",
                    roleKind: recruitment.typeRight,
                    payHourly: recruitment.pay1Value,
                    payAdded: recruitment.pay2Value
                )
                    .navigationTransition(.zoom(sourceID: "card", in: transition))
            }
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .preference(key: VisibilityPreferenceKey.self, value: geometry.frame(in: .global))
                }
            )
            .onPreferenceChange(VisibilityPreferenceKey.self) { frame in
                updateVisibility(frame: frame)
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text("Job card for \(recruitment.titleText) at \(recruitment.companyName) in \(recruitment.location)"))
            .accessibilityAddTraits(.isButton)
            .accessibilityAction(named: Text("Like")) { onLike(recruitment) }
            .accessibilityAction(named: Text("Dislike")) { onDislike(recruitment) }
    }
    
    // MARK: - Card Content
    
    private var cardContent: some View {
        ZStack(alignment: .top) {
            cardBackground
            cardMainContent
            headerOverlay
            swipeOverlay
        }
    }
    
    private var cardBackground: some View {
        ZStack {
            // Placeholder background - always visible
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(Color(.systemGray5))
                .shimmering()
            
            // Actual image content
            AsyncImage(url: recruitment.headerImageURL) { phase in
                switch phase {
                case .empty:
                    Color.clear
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .overlay(
                            LinearGradient(
                                gradient: Gradient(colors: [.clear, .white.opacity(0.7)]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .overlay(
                            LinearGradient(
                                gradient: Gradient(colors: [.clear, .clear, .white.opacity(0.6), .white.opacity(0.9)]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .overlay(
                            Rectangle()
                                .fill(.ultraThinMaterial)
                                .mask {
                                    VStack(spacing: 0) {
                                        LinearGradient(
                                            colors: [
                                                Color.black.opacity(1),
                                                Color.black.opacity(0.1),
                                                Color.black.opacity(0.1),
                                                Color.black.opacity(0.1),
                                                Color.black.opacity(0),
                                            ],
                                            startPoint: .bottom,
                                            endPoint: .top
                                        )
                                        Rectangle()
                                    }
                                }
                        )
                        //header
                        .frame(width: UIScreen.main.bounds.width * 0.928)
                        .frame(height: UIScreen.main.bounds.height * 0.62)
                        .opacity(imageOpacity)
                        .onAppear {
                            withAnimation(.easeIn(duration: 0.35)) {
                                imageOpacity = 1
                            }
                        }
                case .failure:
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .fill(Color.gray.opacity(0.25))
                @unknown default:
                    Color.clear
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
        .overlay(
                        RoundedRectangle(cornerRadius: 32, style: .continuous)
                            .strokeBorder(.ultraThinMaterial, lineWidth: 1.2)
                    )
        //.shadow(color: Color.black.opacity(1.8), radius: 4, x: 0, y: 24)
    }
    
    private var cardMainContent: some View {
        VStack(spacing: 0) {
            Spacer()
            cardDetailsSection
        }
    }
    
    // MARK: - Header Section
    
    private var headerOverlay: some View {
        HStack(alignment: .center) {
            Spacer()
            badgePill
        }
        .padding(20)
    }
    
    private var badgePill: some View {
        HStack {
            Image("LogoSmall")
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 25)
            Text(recruitment.badgeText)
                .fixedSize(horizontal: true, vertical: false)
        }
            .font(.headline)
            .lineLimit(1)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                LinearGradient(colors: [.purple, .purple], startPoint: .top, endPoint: .bottom)
                    .overlay(
                        LinearGradient(colors: [.clear, .white.opacity(0.2)], startPoint: .bottom, endPoint: .top)
                    )
                    .clipShape(Capsule())
                    .overlay(
                        Capsule()
                            .strokeBorder(Color.white.opacity(0.4), lineWidth: 0.5)
                    )
            )
            .foregroundStyle(.white)
    }
    
    // MARK: - Details Section
    
    private var cardDetailsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            titleRow
            Divider()
            industryAndTypeRow
                .padding(.bottom, -12)
            salaryRow
                .padding(.bottom, -4)
            tagsRow
            Divider()
            bottomRow
                .padding(.top, 8)
        }
        .padding(20)
    }
    
    private var titleRow: some View {
            HStack(alignment: .center, spacing: 20) {
                ZStack {
                    Image(recruitment.companyLogo)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 70, height: 70)
                        .clipShape(Circle())
                }
                VStack(alignment: .leading) {
                    Text(recruitment.titleText)
                        .font(.title2)
                        .fixedSize(horizontal: false, vertical: true)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                        .lineLimit(2)
                    Text(recruitment.companyName)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
        }
    }
    
    private var industryAndTypeRow: some View {
        HStack(alignment: .firstTextBaseline) {
            HStack {
                labelChip(text: "業界", symbol: "briefcase.fill", chipColor: .black)
                    .fontWeight(.semibold)
                pill(text: String(recruitment.industryRight.prefix(7)))
                    .lineLimit(1)
                    .padding(.trailing, 20)
                    .fontWeight(.semibold)
            }
            HStack {
                labelChip(text: "種別", symbol: "square.grid.2x2.fill", chipColor: .black)
                    .fontWeight(.semibold)
                pill(text: String(recruitment.typeRight.prefix(4)))
                    .lineLimit(1)
                    .fontWeight(.semibold)
            }
        }
    }
    
    private var salaryRow: some View {
        ZStack {
            // Dot grid background
            Canvas { context, size in
                let dotSpacing: CGFloat = 20
                let dotRadius: CGFloat = 1.5
                
                let columns = Int(size.width / dotSpacing)
                let rows = Int(size.height / dotSpacing)
                
                for row in 0...rows {
                    for column in 0...columns {
                        let x = CGFloat(column) * dotSpacing
                        let y = CGFloat(row) * dotSpacing
                        
                        let dotPath = Circle()
                            .path(in: CGRect(x: x - dotRadius, y: y - dotRadius, width: dotRadius * 2, height: dotRadius * 2))
                        
                        context.fill(dotPath, with: .color(.gray.opacity(0.2)))
                    }
                }
            }
            .frame(height: 100)
            //.padding(.horizontal, -4)
            .allowsHitTesting(false)
            
            // Decorative background chart - only render when visible
            if isChartVisible {
                Chart {
                    ForEach(Array(chartData.enumerated()), id: \.offset) { index, value in
                        LineMark(
                            x: .value("Index", index),
                            y: .value("Value", animateChart ? value : 0)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.accentColor.opacity(0.4), Color.accentColor.opacity(0.1)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .interpolationMethod(.catmullRom)
                        .lineStyle(StrokeStyle(lineWidth: 2.5))
                        
                        AreaMark(
                            x: .value("Index", index),
                            y: .value("Value", animateChart ? value : 0)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.accentColor.opacity(0.15), Color.accentColor.opacity(0.00)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .interpolationMethod(.catmullRom)
                    }
                }
                .chartXAxis(.hidden)
                .chartYAxis(.hidden)
                .chartYScale(domain: 0...100)
                .frame(height: 100)
                .padding(.horizontal, -10)
                .mask(
                    LinearGradient(
                        colors: [.clear, .black, .black, .black, .clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .allowsHitTesting(false)
            }
            
            // Original salary content
            HStack(alignment: .firstTextBaseline, spacing: 0) {
                VStack(alignment: .leading, spacing: 6) {
                    labelChip(text: "新卒年収", chipColor: .purple)
                        .fontWeight(.semibold)
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(alignment: .bottom, spacing: 2) {
                            Text(recruitment.pay1Value)
                                .fixedSize(horizontal: true, vertical: true)
                                .font(.title) 
                                .fontWeight(.heavy)
                            Text("万円")
                                .font(.title3)
                                .fontWeight(.heavy)
                                .padding(.bottom, 3)
                        }
                        Text("000万円~")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()
                Image("Arrow")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40)
                    .offset(y: 45)
                    .opacity(0.3)
                Spacer()
                VStack(alignment: .trailing, spacing: 6) {
                    labelChip(text: "30歳年収", chipColor: .purple)
                        .fontWeight(.semibold)
                    VStack(alignment: .trailing, spacing: 2) {
                        HStack(alignment: .bottom, spacing: 2) {
                            Text(recruitment.pay2Value)
                                .fixedSize(horizontal: true, vertical: true)
                                .font(.title)
                                .fontWeight(.heavy)
                            Text("万円")
                                .font(.title3)
                                .fontWeight(.heavy)
                                .padding(.bottom, 3)
                        }
                        Text("0000万円~")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .onAppear {
            // Mark chart as visible
            isChartVisible = true
            
            // Generate ascending data points with some variation
            let startValue = Double.random(in: 15...25)
            chartData = (0..<8).map { index in
                let baseIncrease = Double(index) * 7.0 // Steady increase per point
                let variation = Double.random(in: -2...4) // Small random variation, biased upward
                return startValue + baseIncrease + variation
            }
            
            // Animate the chart with a spring animation
            withAnimation(.spring(response: 1.2, dampingFraction: 0.7).delay(0.2)) {
                animateChart = true
            }
            
            // Optional: Continuous subtle animation that maintains upward trend
            Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
                withAnimation(.easeInOut(duration: 2.0)) {
                    chartData = chartData.enumerated().map { index, value in
                        let smallVariation = Double.random(in: -1...2) // Slight variation, still biased upward
                        let newValue = value + smallVariation
                        // Ensure each point is generally higher than the previous
                        if index > 0 {
                            return max(chartData[index - 1] + 1, min(85, newValue))
                        }
                        return max(30, min(85, newValue))
                    }
                }
            }
        }
        .onDisappear {
            // Mark chart as not visible to stop rendering
            isChartVisible = false
            animateChart = false
        }
    }
    
    private var tagsRow: some View {
        HStack(spacing: 12) {
            tag(text: recruitment.tag1)
                .font(.caption)
                .lineLimit(1)
            tag(text: recruitment.tag2)
                .font(.caption)
                .lineLimit(1)
            tag(text: recruitment.tag3)
                .font(.caption)
                .lineLimit(1)
            Spacer()
        }
    }
    
    private var bottomRow: some View {
        HStack(alignment: .center) {
            Image(systemName: "clock")
            Text("応募締切")
                .font(.headline)
            Text("\(recruitment.deadline)")
                .font(.body)
                .lineLimit(1)
            Spacer()
            Text(recruitment.classification)
                .font(.headline)
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)
                .foregroundColor(.accentColor)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule().fill(.thinMaterial)
                        .overlay(
                            Capsule()
                                .fill(Color.white.opacity(0.8))
                        )
                )
                .padding(.vertical, -5)
        }
    }
    
    // MARK: - Swipe Overlay
    
    private var swipeOverlay: some View {
        ZStack {
            if translation.width > 30 {
                likeOverlay
            } else if translation.width < -30 {
                dislikeOverlay
            }
        }
    }
    
    private var likeOverlay: some View {
        ZStack {
            LinearGradient(
                colors: [Color.accentColor.opacity(0.2), Color.accentColor.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .opacity(overlayOpacity(for: translation.width))
            .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
            .transition(.opacity)
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(.ultraThinMaterial)
                .opacity(overlayOpacity(for: translation.width))
                .transition(.opacity)
            Color.clear.opacity(0.0)
                .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
                .transition(.opacity)
                .overlay(
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.45), lineWidth: 1.2)
                )
            
            VStack(alignment: .leading) {
                HStack(alignment: .top) {
                    VStack {
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
                                    .offset(x: circleOffset)
                                    .id("likeCircle") // Unique ID to isolate animation state
                            }
                            .frame(width: 160, height: 40)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                        }
                        .frame(width: 160, height: 40)
                        .padding()
                        .onAppear {
                            startCircleAnimation()
                        }
                        .onDisappear {
                            circleAnimationTask?.cancel()
                        }
                        
                        VStack(alignment: .center, spacing: 4) {
                            Text("右にフリックして完了")
                                .font(.headline)
                                .foregroundColor(.white)
                            Text("お気に入り")
                                .font(.title)
                                .fontWeight(.semibold)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .foregroundStyle(.white)
                    }
                    .padding(20)
                    //Spacer()
                }
            }
            .allowsHitTesting(false)
        }
    }
    
    private var dislikeOverlay: some View {
        ZStack {
            LinearGradient(
                colors: [Color.black.opacity(0.2), Color.black.opacity(0.8)],
                startPoint: .topTrailing,
                endPoint: .bottomLeading
            )
                .opacity(overlayOpacity(for: -translation.width))
                .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
                .transition(.opacity)
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(.ultraThinMaterial)
                .opacity(overlayOpacity(for: -translation.width))
                .transition(.opacity)
            Color.clear.opacity(0.0)
                .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
                .transition(.opacity)
                .overlay(
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.45), lineWidth: 1.2)
                )
            
            VStack {
                VStack {
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
                                .offset(x: circleOffset)
                                .id("dislikeCircle") // Unique ID to isolate animation state
                        }
                        .frame(width: 160, height: 40)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    }
                    .frame(width: 160, height: 40)
                    .padding()
                    .onAppear {
                        startCircleAnimation(reversed: true)
                    }
                    .onDisappear {
                        circleAnimationTask?.cancel()
                    }
                    
                    VStack(alignment: .center, spacing: 4) {
                        Text("左にフリックして完了")
                            .font(.headline)
                            .foregroundColor(.white)
                        Text("スキップ")
                            .font(.title)
                            .fontWeight(.semibold)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .foregroundStyle(.white)
                }
                .padding(20)
            }
            .allowsHitTesting(false)
        }
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
            
            // Apply resistance based on velocity (higher velocity = more resistance)
            let resistanceFactor = 1.0 / (1.0 + velocityResistanceFactor * velocityX / 1000.0)
            
            // Apply the resistance to the translation
            let resistedWidth = lastTranslation.width + (deltaX * resistanceFactor)
            let resistedHeight = lastTranslation.height + ((value.translation.height - lastTranslation.height) * resistanceFactor)
            
            translation = CGSize(width: resistedWidth, height: resistedHeight)
            
            lastTranslation = translation
            lastUpdateTime = currentTime
        } else {
            translation = value.translation
        }
    }
    
    private func handleDragEnded(_ value: DragGesture.Value) {
        let shouldLike = translation.width > swipeThreshold
        let shouldDislike = translation.width < -swipeThreshold

        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
            if shouldLike {
                translation = CGSize(width: 1000, height: translation.height)
            } else if shouldDislike {
                translation = CGSize(width: -1000, height: translation.height)
            } else {
                translation = .zero
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            if shouldLike {
                onLike(recruitment)
            } else if shouldDislike {
                onDislike(recruitment)
            }
            isDragging = false
            lastTranslation = .zero
        }
    }
    
    // MARK: - Helper Functions
    
    private func startCircleAnimation(reversed: Bool = false) {
        // Cancel any existing animation task
        circleAnimationTask?.cancel()
        
        // Calculate the distance the circle can travel
        // Capsule width is 160, circle diameter is 36
        // Maximum offset = (160 - 36) / 2 = 62
        let maxOffset: CGFloat = 62
        
        // Set start and end positions based on direction
        let startPosition = reversed ? maxOffset : -maxOffset
        let endPosition = reversed ? -maxOffset : maxOffset
        
        // Start position immediately without animation to prevent glitches
        circleOffset = startPosition
        
        // Create a new animation task
        circleAnimationTask = Task { @MainActor in
            // Small delay to ensure the view is ready
            try? await Task.sleep(nanoseconds: 50_000_000) // 0.05 seconds
            
            guard !Task.isCancelled else { return }
            
            // Animate to end position with easeInOut
            withAnimation(.easeInOut(duration: 1.0)) {
                circleOffset = endPosition
            }
            
            // Wait for animation to complete
            try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
            
            guard !Task.isCancelled else { return }
            
            // Spring back to start with constrained animation
            withAnimation(.spring(response: 0.8, dampingFraction: 0.75)) {
                circleOffset = startPosition
            }
            
            // Wait before next cycle
            try? await Task.sleep(nanoseconds: 800_000_000) // 0.8 seconds
            
            guard !Task.isCancelled else { return }
            
            // Repeat the cycle
            startCircleAnimation(reversed: reversed)
        }
    }
    
    private func startShakeAnimation() {
        withAnimation(
            .spring(response: 0.5, dampingFraction: 0.5)
            .repeatForever(autoreverses: true)
        ) {
            shakeOffset = 12
        }
    }
    
    private func updateVisibility(frame: CGRect) {
        let screenBounds = UIScreen.main.bounds
        
        // Calculate the visible area of the card
        let visibleWidth = min(frame.maxX, screenBounds.maxX) - max(frame.minX, 0)
        let visibleHeight = min(frame.maxY, screenBounds.maxY) - max(frame.minY, 0)
        
        // Calculate percentage of card that's visible
        let visibleArea = visibleWidth * visibleHeight
        let totalArea = frame.width * frame.height
        let visibilityPercentage = totalArea > 0 ? visibleArea / totalArea : 0
        
        // Only render chart if at least 50% of the card is visible and not being dragged off screen
        let shouldBeVisible = visibilityPercentage > 0.5 && abs(translation.width) < 200
        
        if isChartVisible != shouldBeVisible {
            isChartVisible = shouldBeVisible
        }
    }
    
    private func overlayOpacity(for width: CGFloat) -> Double {
        min(max(Double((width - 20) / 90), 0), 1.0)
    }
    
    private func labelChip(text: String, symbol: String? = nil, chipColor: Color? = nil) -> some View {
        HStack(spacing: 4) {
            if let symbol = symbol {
                Image(systemName: symbol)
                    .font(.caption.weight(.medium))
                    .foregroundColor(.white)
            }
            Text(text)
                .font(.subheadline.weight(.medium))
                .foregroundColor(.white)
        }
        .fixedSize(horizontal: true, vertical: true)
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(
            Group {
                if let chipColor = chipColor {
                    Capsule()
                        .fill(chipColor.opacity(0.85))
                        .overlay(
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [.black.opacity(0.0), .black.opacity(0.0)],
                                        startPoint: .bottom,
                                        endPoint: .top
                                    )
                                )
                        )
                        .overlay(
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [.clear, .white.opacity(0.3)],
                                        startPoint: .bottom,
                                        endPoint: .top
                                    )
                                )
                        )
                } else {
                    Capsule().fill(.thinMaterial)
                        .overlay(
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [.clear, .white],
                                        startPoint: .bottom,
                                        endPoint: .top
                                    )
                                )
                        )
                }
            }
        )
        .overlay(
            Capsule()
                .strokeBorder(.white.opacity(0.5), lineWidth: 1)
        )
        .foregroundStyle(chipColor ?? .black)
    }

    @ViewBuilder
    private func badge(text: String, color: Color) -> some View {
        Text(text)
            .font(.headline.weight(.bold))
            //.padding(.horizontal, 12)
            .padding(.vertical, 6)
            //.background(
                //RoundedRectangle(cornerRadius: 8, style: .continuous)
                    //.fill(color.opacity(0.15))
            //)
            //.overlay(
                //RoundedRectangle(cornerRadius: 8, style: .continuous)
                    //.stroke(color, lineWidth: 2)
            //)
            //.foregroundStyle(color)
    }

    @ViewBuilder
    private func pill(text: String) -> some View {
        Text(text)
            .font(.subheadline)
            .fixedSize(horizontal: true, vertical: true)
            .padding(.leading, 3)
            .foregroundStyle(.primary)
    }

    @ViewBuilder
    private func tag(text: String) -> some View {
        Text(text)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule().fill(.thinMaterial)
                    .overlay(
                        Capsule()
                            .fill(Color.white.opacity(0.8))
                    )
            )
            .foregroundStyle(.primary)
    }
}

#Preview {
    ZStack {
        LinearGradient(colors: [.indigo.opacity(0.0), .purple.opacity(0.0)], startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()
        RecruitmentCardView(
            recruitment: Recruitment(
                companyName: "SMBCSMBCアビエーションキャピタル事業本部",
                companyLogo: "SMBCAC",
                badgeText: "Percify特別選考",
                titleText: "SMBCアビエーションキャピタル事業本部MB",
                industryLeft: "NULL",
                industryRight: "ああああMBCSMBCアビエーションキャピタル",
                typeLeft: "NULL",
                typeRight: "ああああMBCSMBCアビエーションキャピタル",
                pay1Label: "Pay1",
                pay1Value: "520",
                pay2Label: "Pay2",
                pay2Value: "2240",
                tag1: "#Tag Text 1MBCSMBCアビエーションキャ",
                tag2: "#Tag Text 2MBCSMBCアビエーションキャ",
                tag3: "#Tag Text 3MBCSMBCアビエーションキャ",
                deadline: "20XX/X/XMBCSMBCアビエーションキャ",
                classification: "インターン",
                headerImageURL: URL(string: "https://www.aeroflap.com.br/wp-content/uploads/2023/11/SMBC-Aviation-Capital-_1_.webp")!,
                location: "Tokyo"
            ),
            onLike: { _ in },
            onDislike: { _ in }
        )
        .padding()
    }
}
