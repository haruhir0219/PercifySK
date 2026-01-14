//
//  SkippedListView.swift
//  Percify
//
//  Created by 松本知大 on 2025/12/10.
//

import SwiftUI

struct SkippedListView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var jobStore: JobStore
    @Namespace private var transition
    @State private var selectedJob: Recruitment?
    
    var body: some View {
        NavigationStack {
            ZStack {
                if jobStore.skippedJobs.isEmpty {
                    // Empty state
                    VStack(spacing: 16) {
                        Image(systemName: "xmark.circle")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        VStack(spacing: 3) {
                            Text("スキップした求人はありません")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            Text("興味のない求人を左にスワイプして\nスキップできます。")
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
                            ForEach(jobStore.skippedJobs) { recruitment in
                                RecruitmentCardCompactView(recruitment: recruitment)
                                    .onTapGesture {
                                        selectedJob = recruitment
                                    }
                                    .contextMenu {
                                        Button(role: .destructive) {
                                            withAnimation {
                                                jobStore.removeSkippedJob(recruitment)
                                            }
                                        } label: {
                                            Label("スキップリストから削除", systemImage: "xmark.circle")
                                        }
                                    }
                                    //.shadow(color: Color.black.opacity(0.15), radius: 12, x: 0, y: 4)
                            }
                        }
                        .padding()
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
            .navigationTitle("スキップした求人")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
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
                    withAnimation {
                        jobStore.moveAllSkippedToLiked()
                    }
                    dismiss()
                }) {
                    Text("\(jobStore.skippedJobs.count)件をお気に入りに移動")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                }
                .buttonStyle(.glass)
                .frame(width: UIScreen.main.bounds.width * 0.8)
                .disabled(jobStore.skippedJobs.isEmpty)
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
    SkippedListView(jobStore: JobStore())
}
