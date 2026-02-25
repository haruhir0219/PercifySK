//
//  ProfileSettingItemPlaceholderView.swift
//  Percify
//
//  Created by 松本知大 on 2026/02/25.
//

import SwiftUI

struct ProfileSettingItemPlaceholderView: View {
    let icon: String
    let title: String
    let gradientColors: [Color]

    var body: some View {
        List {
            //Header begin
            Section() {
                VStack(alignment: .leading, spacing: 6) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color.white)
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: gradientColors),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .strokeBorder(
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color.white.opacity(0.6), Color.white.opacity(0.0), Color.white.opacity(0.3)]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1.2
                                    )
                            )
                        Image(systemName: icon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 36, height: 36)
                            .foregroundColor(Color(.white))
                            .symbolColorRenderingMode(.gradient)
                            .fontWeight(.semibold)
                    }
                    .frame(width: 60, height: 60)
                    .padding(.bottom, 8)
                    Text(title)
                        .font(.title3)
                        .fontWeight(.semibold)
                    Text("マイページ設定アイテムの説明。")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
                .padding(.all, 3)
            }
            //Header END
            Section() {
                Text("マイページの設定項目等をここに実装してください。")
            }
        }
    }
}

#Preview {
    NavigationStack {
        ProfileSettingItemPlaceholderView(
            icon: "bell.badge.fill",
            title: "通知設定",
            gradientColors: [.pink.opacity(0.5), .pink]
        )
    }
}
