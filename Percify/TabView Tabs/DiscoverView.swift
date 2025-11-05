import SwiftUI
import UIKit

struct DiscoverView: View {
    @Namespace var transition
    @State private var isShowingSearch = false
    @State private var isShowingMembership = false
    @State private var jobStore = JobStore()
    @State private var baseOffsets: [String: CGFloat] = [:]

    private enum SwipeResult { case like, dislike }

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

    private func undoLastSwipe() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
            jobStore.undoLastSwipe()
        }
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.indigo.opacity(0.6), Color.purple.opacity(0.2), //Color(.systemGroupedBackground)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
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
                            Text("あなたへのおすすめは全て\n確認しました。")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                            
                            // Display statistics when all cards are swiped
                            VStack(spacing: 12) {
                                HStack(spacing: 24) {
                                    VStack(spacing: 4) {
                                        Text("\(jobStore.likeCount)")
                                            .font(.title)
                                            .fontWeight(.bold)
                                            .fontDesign(.rounded)
                                            .foregroundColor(.accentColor)
                                        Text("お気に入り")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    VStack(spacing: 4) {
                                        Text("\(jobStore.skipCount)")
                                            .font(.title)
                                            .fontWeight(.bold)
                                            .fontDesign(.rounded)
                                            .foregroundColor(.black)
                                        Text("スキップ")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    VStack(spacing: 4) {
                                        Text("\(jobStore.totalInteractions)")
                                            .font(.title)
                                            .fontWeight(.bold)
                                            .fontDesign(.rounded)
                                            .foregroundColor(.blue)
                                        Text("合計")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                            .padding(.horizontal)
                                    }
                                }
                                .padding(.all, 6)
                                .padding()
                                .glassEffect(.clear.interactive())
                            }
                            .padding(.top, 24)
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
                        }
                    } else {
                        ForEach(Array(jobStore.cards.enumerated()), id: \.element.id) { index, item in
                            // Randomize only the tilt direction; keep magnitude fixed at 1.5°
                            let seed = UInt64(index + 1)
                            let sign: Double = ((Int(seed & 1) == 0) ? 1.0 : -1.0)
                            let angle = Angle(degrees: 1.5 * sign)
                            // Slight vertical offset so the stack looks layered
                            let key = "\(item.titleText)|\(item.companyName)|\(item.location)"
                            let verticalOffset: CGFloat = baseOffsets[key] ?? CGFloat((jobStore.cards.count - 1 - index)) * 6.0
                            // Slight z offset to ensure layering looks natural
                            let z = Double(index)
                            let isTopCard = index == jobStore.cards.count - 1
                            
                            RecruitmentCardView(
                                recruitment: item,
                                onLike: { liked in
                                    handleSwipe(result: .like, item: liked)
                                },
                                onDislike: { disliked in
                                    handleSwipe(result: .dislike, item: disliked)
                                }
                            )
                            .padding(.horizontal)
                            .padding(.vertical, 12)
                            .onAppear {
                                if baseOffsets[key] == nil {
                                    baseOffsets[key] = CGFloat((jobStore.cards.count - 1 - index)) * 6.0
                                }
                            }
                            // Apply tiny tilt and stacking offsets; keep top card hit-testable
                            .rotationEffect(angle)
                            .offset(y: verticalOffset)
                            .zIndex(z)
                            .allowsHitTesting(isTopCard)
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .animation(.spring(response: 0.45, dampingFraction: 0.9), value: jobStore.isEmpty)
                .padding(.bottom, 30)
            }
            
            //.navigationTitle("さがす")
            .safeAreaBar(edge: .bottom) {HStack(spacing: 48) {
                Button {
                    if let top = jobStore.cards.last { handleSwipe(result: .dislike, item: top) }
                } label: {
                    HStack(spacing: 8) {
                        Text(String(jobStore.skipCount))
                            .fontDesign(.rounded)
                            .font(.headline)
                            .fontWeight(.bold)
                            .contentTransition(.numericText())
                            .animation(.snappy, value: jobStore.skipCount)
                        Text("スキップ　")
                            .font(.headline)
                    }
                    .padding(.all, 8)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, -8)
                }
                .buttonStyle(.glassProminent)
                .tint(.black)
                .disabled(jobStore.isEmpty)
                
                Button {
                    undoLastSwipe()
                } label: {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.headline)
                        .padding(.all, 8)
                        .padding(.horizontal, -3)
                        .foregroundColor(jobStore.canUndo ? .accentColor : .secondary)
                }
                .buttonStyle(.glass)
                .controlSize(.small)
                .disabled(!jobStore.canUndo)
                .padding(.horizontal, -25)
                
                Button {
                    if let top = jobStore.cards.last { handleSwipe(result: .like, item: top) }
                } label: {
                    HStack(spacing: 8) {
                        Text("お気に入り")
                            .font(.headline)
                        Text(String(jobStore.likeCount))
                            .fontDesign(.rounded)
                            .font(.headline)
                            .fontWeight(.bold)
                            .contentTransition(.numericText())
                            .animation(.snappy, value: jobStore.likeCount)
                    }
                    .padding(.all, 8)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, -8)
                }
                .buttonStyle(.glassProminent)
                //.tint(.green)
                .disabled(jobStore.isEmpty)
            }
            .padding(.horizontal, 6)
            .padding(.horizontal)
            .padding(.bottom)
            }
            //.padding(.top, 15)
            //.padding(.bottom, 40)
        }
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Image("PercifySK")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 42, height: 42)
            }
            ToolbarItemGroup(placement: .topBarLeading) {
                HStack {
                    HStack {
                        Button(action: { isShowingMembership = true }) {
                            Image(systemName: "chart.bar.fill")
                        }
                    }
                    .matchedTransitionSource(id: "membership", in: transition)
                }
                .buttonStyle(.glassProminent)
            }
            ToolbarSpacer(.fixed)
            ToolbarSpacer(.fixed, placement: .topBarTrailing)
            ToolbarItemGroup(placement: .topBarTrailing) {
                HStack {
                    Button(action: { isShowingSearch = true }) {
                        Image(systemName: "line.3.horizontal.decrease")
                    }
                }
                .matchedTransitionSource(id: "search", in: transition)
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
    }
}

#Preview {
    NavigationStack {
        DiscoverView()
    }
}
