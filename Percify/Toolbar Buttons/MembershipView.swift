//
//  SearchView.swift
//  Percify
//
//  Created by 松本知大 on 2025/10/20.
//

import SwiftUI

struct MembershipView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
                ZStack {
                    // Full-screen background
                    Color(.systemGroupedBackground)
                        .padding(-200)
                        .padding(.vertical, -1000)
                    //.ignoresSafeArea()
                        .edgesIgnoringSafeArea(.all)
                
                ScrollView(.vertical, showsIndicators: true) {
                    List {
                        Section {
                            VStack(spacing: 18) {
                                    Image(systemName: "chart.bar.fill")
                                        .font(.largeTitle)
                                        .foregroundColor(.white)
                                        .symbolColorRenderingMode(.gradient)
                                        .padding()
                                        .glassEffect(.regular.tint(.accentColor), in: .circle)
                                .padding(.bottom, 6)
                                Text("ランクが高いほど、\n企業からスカウトが届く。")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                                    .multilineTextAlignment(.center)
                                    .padding(.bottom, 10)
                                    Text("Percifyランクは、あなたのPercify就活へのエンゲージメントを「可視化」したものです。Percify就活の掲載企業は、利用頻度の高いアクティブな学生にスカウトを送ります。企業にアクティブさをアピールして、一流企業からスカウトを受け取りましょう!")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.bottom, 10)
                            }
                            .padding(.horizontal, 6)
                            .padding(.vertical)
                            .frame(maxWidth: .infinity)
                            .listRowBackground(LinearGradient(
                                colors: [
                                    Color.indigo.opacity(0.6), Color.purple.opacity(0.18), Color(.white), Color(.white)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            ))
                        }
                        Section(header: Text("会員ステータス")) {
                            VStack {
                                Text("ランクはまだご利用いただけません")
                                    .foregroundColor(.secondary)
                            }
                        }
                        Section(header: Text("ランク制度")) {
                            VStack {
                                ProgressView()
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                    //.scrollContentBackground(.hidden)
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 800)
                }
            }
            .navigationTitle("メンバーシップ")
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                    }
                    .foregroundColor(.primary)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        MembershipView()
    }
}
