import SwiftUI

struct Recruitment: Identifiable, Equatable {
    let id = UUID()
    let companyName: String
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

    // Haptic feedback generators
    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    private let impactMedium = UIImpactFeedbackGenerator(style: .medium)

    // Thresholds
    private let swipeThreshold: CGFloat = 120
    private let velocityResistanceFactor: CGFloat = 0.3 // Lower = more resistance

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.15), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.15), radius: 12, x: 0, y: 8)

            VStack(spacing: 0) {
                // Header image with top overlays
                ZStack(alignment: .topLeading) {
                    AsyncImage(url: recruitment.headerImageURL) { phase in
                        switch phase {
                        case .empty:
                            Color(.secondarySystemBackground)
                                .shimmering()
                                //.overlay(ProgressView())
                                .frame(maxWidth: .infinity)
                                .frame(maxHeight: .infinity)
                                .clipped()
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: UIScreen.main.bounds.width * 0.928)
                                .frame(maxHeight: .infinity)
                                .clipped()
                        case .failure:
                            Rectangle().fill(Color.gray.opacity(0.25))
                                .overlay(Image(systemName: "photo").font(.largeTitle))
                                .frame(maxWidth: .infinity)
                                .frame(height: 240)
                                .clipped()
                        @unknown default:
                            Rectangle().fill(Color.gray.opacity(0.15))
                                .frame(maxWidth: .infinity)
                                .frame(height: 240)
                                .clipped()
                        }
                    }

                    HStack(alignment: .center) {
                        Text(recruitment.companyName)
                            .font(.headline)
                            .foregroundStyle(.primary)
                            .lineLimit(1)
                        Spacer()
                        Text(recruitment.badgeText)
                            .font(.headline)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                LinearGradient(colors: [.purple, .pink], startPoint: .leading, endPoint: .trailing)
                                    .clipShape(Capsule())
                            )
                            .foregroundStyle(.white)
                    }
                    .padding(20)
                }

                // Title row with avatar dot and large title
                VStack(alignment: .leading, spacing: 16) {
                    HStack(alignment: .center, spacing: 20) {
                        Circle()
                            .fill(LinearGradient(colors: [.gray.opacity(0.25), .gray.opacity(0.8)], startPoint: .top, endPoint: .bottom))
                            .frame(width: 60, height: 60)
                        Text(recruitment.titleText)
                            .font(.title)
                            .fixedSize(horizontal: false, vertical: true)
                            .fontWeight(.semibold)
                            .foregroundStyle(.primary)
                            .lineLimit(2)
                    }

                    Divider()

                    // Chips rows (Industry / Type / Pay)
                    HStack(alignment: .firstTextBaseline) {
                        Text("業界")
                            .font(.headline.weight(.bold))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(
                                Capsule().fill(LinearGradient(colors: [.black.opacity(0.6), .black], startPoint: .top, endPoint: .bottom))
                            )
                            .foregroundStyle(.white)
                        //Spacer(minLength: 10)
                        pill(text: recruitment.industryRight)
                            .padding(.trailing, 20)
                        //Spacer(minLength: 10)
                        Text("種別")
                            .font(.headline.weight(.bold))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(
                                Capsule().fill(LinearGradient(colors: [.black.opacity(0.6), .black], startPoint: .top, endPoint: .bottom))
                            )
                            .foregroundStyle(.white)
                        //Spacer(minLength: 10)
                        pill(text: recruitment.typeRight)
                    }

                    HStack(alignment: .firstTextBaseline) {
                        Text("新卒年収")
                            .font(.headline.weight(.bold))
                            .fixedSize(horizontal: true, vertical: true)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(
                                Capsule().fill(LinearGradient(colors: [.black.opacity(0.6), .black], startPoint: .top, endPoint: .bottom))
                            )
                            .foregroundStyle(.white)
                        Text(recruitment.pay1Value)
                            .fixedSize(horizontal: true, vertical: true)
                            .font(.body)
                        Spacer()
                        Text("30歳年収")
                            .font(.headline.weight(.bold))
                            .fixedSize(horizontal: true, vertical: true)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(
                                Capsule().fill(LinearGradient(colors: [.black.opacity(0.6), .black], startPoint: .top, endPoint: .bottom))
                            )
                            .foregroundStyle(.white)
                        Text(recruitment.pay2Value)
                            .fixedSize(horizontal: true, vertical: true)
                            .font(.body)
                    }

                    // Tags
                    HStack(spacing: 12) {
                        tag(text: recruitment.tag1)
                            .font(.caption)
                            //.fixedSize(horizontal: true, vertical: true)
                            .lineLimit(1)
                        tag(text: recruitment.tag2)
                            .font(.caption)
                            //.fixedSize(horizontal: true, vertical: true)
                            .lineLimit(1)
                        tag(text: recruitment.tag3)
                            .font(.caption)
                            //.fixedSize(horizontal: true, vertical: true)
                            .lineLimit(1)
                        Spacer()
                    }

                    Divider()

                    // Bottom row
                    HStack(alignment: .center) {
                        Text("締め切り: \(recruitment.deadline)")
                            .font(.body)
                        Spacer()
                        Text(recruitment.classification)
                            .font(.headline)
                    }
                }
                .padding(20)
            }
            
            // In-card overlay so it moves with the card (placed last to be topmost)
            ZStack {
                if translation.width > 30 {
                    // Like: green tint overlay
                    ZStack {
                        Color.green
                            .opacity(min(max(Double((translation.width - 20) / 90), 0), 1.0))
                            .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
                            .transition(.opacity)
                        Color.accentColor
                            .opacity(min(max(Double((translation.width - 20) / 90), 0), 1.0))
                            .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
                            .transition(.opacity)
                    }
                    // Optional lightweight label for clarity
                    VStack {
                        HStack {
                            VStack {
                                HStack {
                                    Image(systemName: "arrowshape.turn.up.right.fill")
                                        .font(.title)
                                        .fontWeight(.semibold)
                                    Text("お気に入り")
                                        .font(.title)
                                        .fontWeight(.semibold)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .foregroundStyle(.white)
                                Text("右にフリックして完了")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Spacer()
                            }
                            .padding(20)
                            Spacer()
                        }
                    }
                    .allowsHitTesting(false)
                } else if translation.width < -30 {
                    // Nope: red tint overlay
                    Color.black
                        .opacity(min(max(Double((-translation.width - 20) / 90), 0), 1.0))
                        .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
                        .transition(.opacity)
                    // Optional lightweight label for clarity
                    VStack {
                        HStack {
                            Spacer()
                            VStack {
                                HStack {
                                    Image(systemName: "arrowshape.turn.up.left.fill")
                                        .font(.title)
                                        .fontWeight(.semibold)
                                    Text("スキップ")
                                        .font(.title)
                                        .fontWeight(.semibold)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .foregroundStyle(.white)
                                Text("左にフリックして完了")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(20)
                        Spacer()
                    }
                    .allowsHitTesting(false)
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
        .matchedTransitionSource(id: "card", in: transition)
        .frame(maxWidth: .infinity)
        .frame(height: UIScreen.main.bounds.height * 0.62)
        .rotationEffect(.degrees(Double(translation.width / 20)))
        .offset(x: translation.width, y: translation.height)
        .contentShape(Rectangle())
        .onTapGesture {
            showDetails = true
        }
        .highPriorityGesture(
            DragGesture()
                .onChanged { value in
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
                    
                    // Cross threshold haptic cues
                    if abs(translation.width) > swipeThreshold * 0.6 {
                        impactMedium.prepare()
                        impactMedium.impactOccurred(intensity: 0.8)
                    }
                }
                .onEnded { value in
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
        )
        .animation(.spring(response: 0.3, dampingFraction: 0.9), value: translation)
        .fullScreenCover(isPresented: $showDetails) {
            RecruitmentDetailsView()
                .navigationTransition(.zoom(sourceID: "card", in: transition))
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("Job card for \(recruitment.titleText) at \(recruitment.companyName) in \(recruitment.location)"))
        .accessibilityAddTraits(.isButton)
        .accessibilityAction(named: Text("Like")) { onLike(recruitment) }
        .accessibilityAction(named: Text("Dislike")) { onDislike(recruitment) }
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
            .font(.body)
            .fixedSize(horizontal: true, vertical: true)
            .padding(.leading, 6)
            //.padding(.vertical, 8)
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
                Capsule().fill(Color(.systemGroupedBackground))
            )
            .foregroundStyle(.primary)
    }
}

#Preview {
    ZStack {
        LinearGradient(colors: [.indigo.opacity(0.6), .purple.opacity(0.2)], startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()
        RecruitmentCardView(
            recruitment: Recruitment(
                companyName: "Company Name",
                badgeText: "Badge Text",
                titleText: "Title Text here Brown Fox Corp",
                industryLeft: "Industry",
                industryRight: "Industry",
                typeLeft: "Type",
                typeRight: "Type",
                pay1Label: "Pay1",
                pay1Value: "XX万円",
                pay2Label: "Pay2",
                pay2Value: "XX万円",
                tag1: "#Tag Text 1",
                tag2: "#Tag Text 2",
                tag3: "#Tag Text 3",
                deadline: "20XX/X/X (XXDays)",
                classification: "Classification",
                headerImageURL: URL(string: "https://picsum.photos/465/300")!,
                location: "Tokyo"
            ),
            onLike: { _ in },
            onDislike: { _ in }
        )
        .padding()
    }
}
