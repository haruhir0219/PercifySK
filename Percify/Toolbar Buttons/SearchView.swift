//
//  SearchView.swift
//  Percify
//
//  Created by 松本知大 on 2025/10/20.
//

import SwiftUI

struct SearchView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                // Full-screen background
                Color(.white)
                    .padding(-200)
                    .padding(.vertical, -1000)
                //.ignoresSafeArea()
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    Spacer()
                    Image(systemName: "app.badge")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    Text("この機能は近日提供")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                        .foregroundColor(.secondary)
                        .padding(.top, 8)
                    Text("この機能は、まだご利用いただけません。\n近日の提供開始をお待ちください。")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    Spacer()
                }
            }
            .navigationTitle("絞り込み")
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
        SearchView()
    }
}
