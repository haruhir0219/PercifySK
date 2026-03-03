import SwiftUI

struct FavoriteCompaniesView: View {
    @Bindable var jobStore: JobStore
    @Namespace private var transition
    @State private var selectedJob: Recruitment?

    var body: some View {
        ZStack {
            if jobStore.favoritedRecruitments.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "building.2")
                        .font(.system(size: 60))
                        .foregroundColor(.secondary)
                    VStack(spacing: 3) {
                        Text("お気に入り企業はまだありません")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        Text("求人詳細ページから企業を\nお気に入りに追加しましょう。")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 12),
                        GridItem(.flexible(), spacing: 12)
                    ], spacing: 18) {
                        ForEach(jobStore.favoritedRecruitments) { recruitment in
                            RecruitmentCardCompactView(
                                recruitment: recruitment,
                                isSelected: .constant(false)
                            )
                            .onTapGesture {
                                selectedJob = recruitment
                            }
                            .contextMenu {
                                Button(role: .destructive) {
                                    withAnimation {
                                        jobStore.toggleFavorite(recruitment.id.uuidString)
                                    }
                                } label: {
                                    Label("お気に入りから削除", systemImage: "heart.slash")
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .background(
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
        )
        .navigationTitle("あなたの企業一覧")
        .fullScreenCover(item: $selectedJob) { recruitment in
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
            .navigationTransition(.zoom(sourceID: "favoriteCard", in: transition))
        }
    }
}

#Preview {
    NavigationStack {
        FavoriteCompaniesView(jobStore: JobStore())
    }
}
