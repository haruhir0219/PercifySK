//
//  LikedListView.swift
//  Percify
//
//  Created by 松本知大 on 2025/12/10.
//

import SwiftUI

struct LikedListView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var jobStore: JobStore
    @Namespace private var transition
    @State private var selectedJob: Recruitment?
    @State private var selectedRecruitments: Set<UUID> = []
    
    var body: some View {
        NavigationStack {
            ZStack {
                if jobStore.likedJobs.isEmpty {
                    // Empty state
                    VStack(spacing: 16) {
                        Image(systemName: "heart.slash")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        VStack(spacing: 3) {
                            Text("お気に入りはまだありません")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            Text("気になる求人を右にスワイプして\nお気に入りに追加しましょう。")
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
                            ForEach(jobStore.likedJobs) { recruitment in
                                RecruitmentCardCompactView(
                                    recruitment: recruitment,
                                    isSelected: Binding(
                                        get: { selectedRecruitments.contains(recruitment.id) },
                                        set: { isSelected in
                                            if isSelected {
                                                selectedRecruitments.insert(recruitment.id)
                                            } else {
                                                selectedRecruitments.remove(recruitment.id)
                                            }
                                        }
                                    )
                                )
                                    .onTapGesture {
                                        selectedJob = recruitment
                                    }
                                    .contextMenu {
                                        Button(role: .destructive) {
                                            withAnimation {
                                                jobStore.removeLikedJob(recruitment)
                                            }
                                        } label: {
                                            Label("お気に入りから削除", systemImage: "heart.slash")
                                        }
                                    }
                                    //.shadow(color: Color.black.opacity(0.15), radius: 12, x: 0, y: 4)
                            }
                        }
                        .padding()
                    }
                    .onAppear {
                        // Pre-select all items when the view appears
                        selectedRecruitments = Set(jobStore.likedJobs.map { $0.id })
                    }
                }
            }
            .background(
                LinearGradient(
                    colors: [
                        Color(.systemGroupedBackground),
                        Color(.systemGroupedBackground)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
            .navigationTitle("お気に入り")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        withAnimation {
                            jobStore.undoAllSwipes()
                            dismiss()
                        }
                    } label: {
                        Image(systemName: "arrow.trianglehead.counterclockwise")
                            .foregroundColor(.red)
                            .padding(.bottom, 2)
                    }
                    .disabled(jobStore.likedJobs.isEmpty && jobStore.skippedJobs.isEmpty)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
            }
            .safeAreaBar(edge: .bottom) {
                                        Button(action: {
                                            dismiss()
                                        }) {
                                            Text("\(selectedRecruitments.count)件を選択して一括エントリー")
                                                .font(.headline)
                                                .fontWeight(.semibold)
                                                .frame(maxWidth: .infinity)
                                                .padding(.vertical, 10)
                                                .foregroundColor(.white)
                                                .multilineTextAlignment(.center)
                                        }
                                        .buttonStyle(.glassProminent)
                                        .frame(width: UIScreen.main.bounds.width * 0.8)
                                        .disabled(selectedRecruitments.isEmpty)
                                    }
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
                .navigationTransition(.zoom(sourceID: "card", in: transition))
            }
        }
    }
}

#Preview {
    LikedListView(jobStore: JobStore())
}
