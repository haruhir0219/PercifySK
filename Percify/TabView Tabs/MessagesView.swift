import SwiftUI

struct MessagesView: View {
    @Namespace var transition
    @State private var isShowingSearch = false
    @State private var isShowingMembership = false
    
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
                Spacer()
                VStack {
                    Image(systemName: "app.badge")
                        .font(.system(size: 50))
                        .foregroundColor(.secondary)
                    Text("この機能は近日提供")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                        .foregroundColor(.secondary)
                        .padding(.top, 8)
                    Text("この機能は、まだご利用いただけ\nません。近日の提供開始を\nお待ちください。")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    Button(action: {}) {
                        Text("さがすに戻る")
                    }
                    .buttonStyle(.glassProminent)
                    .controlSize(ControlSize.regular)
                    .padding()
                }
                .padding(.horizontal, 2)
                .padding(.vertical, 40)
                .glassEffect(.clear.interactive(), in: .rect(cornerRadius: 38.0))
                Spacer()
            }
            .padding()
            .navigationTitle("メッセージ")
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
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
}

#Preview {
    NavigationStack {
        MessagesView()
    }
}
