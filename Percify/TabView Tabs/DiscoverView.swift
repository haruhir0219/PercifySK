import SwiftUI
import UIKit
import ConfettiSwiftUI

struct DiscoverView: View {
    @Namespace var transition
    @State private var isShowingSearch = false
    @State private var isShowingMembership = false
    @State private var isShowingSkippedList = false
    @State private var isShowingLikedList = false
    @State private var jobStore = JobStore()
    @State private var confettiTrigger: Int = 0

    private enum SwipeResult { case like, dislike }
    
    // Computed property for header offset based on screen size
    private var headerOffset: CGFloat {
        let screenHeight = UIScreen.main.bounds.height
        return screenHeight <= 844 ? -18 : 0 // 667 is iPhone SE/8 height
    }

    private func handleSwipe(result: SwipeResult, item: Recruitment) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
            switch result {
            case .like:
                jobStore.handleLike(item: item)
            case .dislike:
                jobStore.handleDislike(item: item)
            }
        }
    }
    
    private func handleHintSwipe() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
            jobStore.handleHintSwipe()
        }
    }
    
    private func showHint() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
            jobStore.insertHintCard()
        }
    }

    private func undoLastSwipe() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
            jobStore.undoLastSwipe()
        }
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.indigo.opacity(0.7), Color.purple.opacity(0.15), Color(.systemGroupedBackground), Color(.systemGroupedBackground), Color(.systemGroupedBackground)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .padding(.all, -50)
            .ignoresSafeArea()
            
            VStack {
                ZStack {
                    if jobStore.isEmpty {
                        VStack {
                            Image(systemName: "checkmark.circle")
                                .font(.system(size: 50))
                                .foregroundColor(.secondary)
                            Text("全て閲覧済みです")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.black)
                                .foregroundColor(.secondary)
                                .padding(.top, 8)
                            Text("あなたへのおすすめは全て確認しました。\nお気に入りにスワイプしたポジションを\nチェックして、簡単に応募できます。")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .padding()
                        .scaleEffect(jobStore.isEmpty ? 1.0 : 0.95)
                        .opacity(jobStore.isEmpty ? 1.0 : 0.0)
                        .transition(.asymmetric(
                            insertion: .scale(scale: 0.9).combined(with: .opacity),
                            removal: .opacity
                        ))
                        .onAppear {
                            let generator = UINotificationFeedbackGenerator()
                            generator.prepare()
                            generator.notificationOccurred(.success)
                            confettiTrigger += 1
                        }
                    } else {
                        ForEach(Array(jobStore.cards.enumerated()), id: \.element.id) { index, cardType in
                            let isTopCard = index == jobStore.cards.count - 1
                            // Calculate position in stack (0 = bottom, cards.count-1 = top)
                            let positionFromTop = jobStore.cards.count - 1 - index
                            
                            // Scale: top card = 1.0, each card below shrinks by 2%
                            let scale: CGFloat = 1.0 - (CGFloat(positionFromTop) * 0.05)
                            
                            // Vertical offset: each card below moves down by 8 points
                            let verticalOffset: CGFloat = CGFloat(positionFromTop) * 28.0
                            
                            // Z-index for proper layering
                            let z = Double(index)
                            
                            Group {
                                switch cardType {
                                case .recruitment(let item):
                                    RecruitmentCardView(
                                        recruitment: item,
                                        onLike: { liked in
                                            handleSwipe(result: .like, item: liked)
                                        },
                                        onDislike: { disliked in
                                            handleSwipe(result: .dislike, item: disliked)
                                        }
                                    )
                                case .hint:
                                    HintCardView(onSwipe: handleHintSwipe)
                                }
                            }
                            //.clipped()
                            .padding(.horizontal)
                            .padding(.vertical, 12)
                            .shadow(color: Color.black.opacity(0.15), radius: 12, x: 0, y: 4)
                            // Apply scale and vertical offset for stacking effect
                            .scaleEffect(scale)
                            .offset(y: verticalOffset)
                            .zIndex(z)
                            .allowsHitTesting(isTopCard)
                            .animation(.spring(response: 0.65, dampingFraction: 0.45), value: isTopCard)
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .animation(.spring(response: 0.45, dampingFraction: 0.9), value: jobStore.isEmpty)
                .padding(.bottom, 25)
                .confettiCannon(trigger: $confettiTrigger, num: 170, confettis: [.shape(.circle), .shape(.triangle), .shape(.square), .shape(.slimRectangle)], confettiSize: 11.0, openingAngle: Angle(degrees: 0), closingAngle: Angle(degrees: 360), radius: 300)
            }
            ZStack {
                VStack {
                    ZStack {
                        Rectangle()
                            .fill(Color.clear)
                            .frame(height: 125)
                            .glassEffect(.clear, in: .rect(cornerRadius: 32))
                        ZStack {
                            RoundedRectangle(cornerRadius: 32)
                                .fill(Color.clear)
                                .frame(height: 125)
                            ProgressView(value: jobStore.swipeProgressPercentage, total: 100)
                                .tint(.accentColor)
                                .padding()
                                .offset(y: 60.5)
                                .opacity(jobStore.swipeProgressPercentage == 0 ? 0 : 1)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 32))
                    }
                    .offset(y: headerOffset)
                    
                    Spacer()
                }
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .ignoresSafeArea(edges: .top)
        }
        .overlay(alignment: .bottom) {
            VariableBlurView(maxBlurRadius: 10, direction: .blurredBottomClearTop)
                .frame(height: 180)
        }
        .ignoresSafeArea()
        .safeAreaBar(edge: .bottom) {
                                    Button(action: { }) {
                                        ZStack {
                                            Text(" ")
                                                .font(.headline)
                                                .frame(maxWidth: .infinity)
                                                .padding(.vertical, 10)
                                                .foregroundColor(.black)
                                                .multilineTextAlignment(.center)
                                            HStack(spacing: 42) {
                                                            Button {
                                                                isShowingSkippedList = true
                                                            } label: {
                                                                HStack(spacing: 8) {
                                                                    Text(String(jobStore.skipCount))
                                                                        .fontDesign(.rounded)
                                                                        .font(.headline)
                                                                        .fontWeight(.bold)
                                                                        .contentTransition(.numericText())
                                                                        .animation(.snappy, value: jobStore.skipCount)
                                                                    Text("スキップ　")
                                                                        .font(.subheadline)
                                                                        .fontWeight(.semibold)
                                                                }
                                                                .padding(.all, 8)
                                                                .padding(.vertical, -2)
                                                                .frame(maxWidth: .infinity)
                                                                .padding(.horizontal, -8)
                                                            }
                                                            .matchedTransitionSource(id: "skipped", in: transition)
                                                            .buttonStyle(.glass)
                                                            
                                                            Button {
                                                                undoLastSwipe()
                                                            } label: {
                                                                Image(systemName: "arrow.trianglehead.counterclockwise")
                                                                    .font(.headline)
                                                                    .padding(.all, 6)
                                                                    .padding(.horizontal, -3)
                                                                    .foregroundColor(jobStore.canUndo ? .accentColor : .secondary)
                                                            }
                                                            .buttonStyle(.glass)
                                                            .controlSize(.small)
                                                            .disabled(!jobStore.canUndo)
                                                            .padding(.horizontal, -25)
                                                            
                                                            Button {
                                                                isShowingLikedList = true
                                                            } label: {
                                                                HStack(spacing: 8) {
                                                                    Text("お気に入り")
                                                                        .font(.subheadline)
                                                                        .fontWeight(.semibold)
                                                                    Text(String(jobStore.likeCount))
                                                                        .fontDesign(.rounded)
                                                                        .font(.headline)
                                                                        .fontWeight(.bold)
                                                                        .contentTransition(.numericText())
                                                                        .animation(.snappy, value: jobStore.likeCount)
                                                                }
                                                                .padding(.all, 8)
                                                                .padding(.vertical, -2)
                                                                .frame(maxWidth: .infinity)
                                                                .padding(.horizontal, -8)
                                                            }
                                                            .matchedTransitionSource(id: "liked", in: transition)
                                                            .buttonStyle(.glassProminent).tint(.accentColor.opacity(0.9))
                                                        }
                                                        .padding(.horizontal, -2)
                                                        .padding(.vertical, 1)
                                        }
                                    }
                                    //.buttonStyle(.glass)
                                    .padding(.vertical, -4)
                                    .padding(.all, 10)
                                    .glassEffect(.clear.interactive())
                                    .frame(width: UIScreen.main.bounds.width * 0.91)
                                    .padding(.bottom, 8)
                                }
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Image("PercifySKLockup")
                    .resizable()
                    .scaledToFill()
                    .frame(height: 40)
                    .padding(.leading, -6)
                    //.colorInvert()
            }
            .sharedBackgroundVisibility(.hidden)
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: { showHint() }) {
                    Image(systemName: "questionmark")
                }
            }
            
            ToolbarSpacer(.fixed, placement: .topBarTrailing)
            
            ToolbarItemGroup(placement: .topBarTrailing) {
                    Button(action: { isShowingSearch = true }) {
                        Image(systemName: "line.3.horizontal.decrease")
                    }
                .matchedTransitionSource(id: "search", in: transition)
                    Button(action: { isShowingMembership = true }) {
                        Image(systemName: "magnifyingglass")
                    }
                .matchedTransitionSource(id: "membership", in: transition)
            }
        }
        .sheet(isPresented: $isShowingSearch) {
            SearchView()
                .navigationTransition(.zoom(sourceID: "search", in: transition))
        }
        .sheet(isPresented: $isShowingMembership) {
            MembershipView()
                .navigationTransition(.zoom(sourceID: "membership", in: transition))
        }
        .sheet(isPresented: $isShowingSkippedList) {
            SkippedListView(jobStore: jobStore)
                .navigationTransition(.zoom(sourceID: "skipped", in: transition))
        }
        .sheet(isPresented: $isShowingLikedList) {
            LikedListView(jobStore: jobStore)
                .navigationTransition(.zoom(sourceID: "liked", in: transition))
        }
    }
}

#Preview {
    NavigationStack {
        DiscoverView()
    }
}
