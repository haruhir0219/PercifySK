import SwiftUI

struct ProfileView: View {
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
                ProgressView()
                    .controlSize(.large)
                Text("読み込み中...")
                    .foregroundColor(.secondary)
                    .padding(.top, 6)
                Spacer()
            }
            .padding()
            .navigationTitle("マイページ")
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
        ProfileView()
    }
}
