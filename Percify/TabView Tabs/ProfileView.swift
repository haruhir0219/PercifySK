import SwiftUI

struct ProfileView: View {
    @Namespace var transition
    @State private var isShowingSearch = false
    @State private var isShowingMembership = false
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.indigo.opacity(0.7), Color.purple.opacity(0.15), Color(.systemGroupedBackground), Color(.systemGroupedBackground), Color(.systemGroupedBackground), Color(.systemGroupedBackground), Color(.systemGroupedBackground)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .padding(.all, -50)
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
            .toolbarTitleDisplayMode(.inlineLarge)
            .toolbar {
                ToolbarSpacer(.fixed)
                ToolbarSpacer(.fixed, placement: .topBarTrailing)
                ToolbarItemGroup(placement: .topBarTrailing) {
                    HStack {
                        Button(action: { isShowingMembership = true }) {
                            Image(systemName: "star")
                        }
                    }
                    .matchedTransitionSource(id: "membership", in: transition)
                    HStack {
                        Button(action: { isShowingSearch = true }) {
                            Image(systemName: "line.3.horizontal.decrease")
                        }
                    }
                    .matchedTransitionSource(id: "search", in: transition)
                    HStack {
                        Button(action: { isShowingSearch = true }) {
                            Image(systemName: "magnifyingglass")
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
