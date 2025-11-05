//
//  RecruitmentDetailsView.swift
//  Percify
//
//  Created by 松本知大 on 2025/11/05.
//

import SwiftUI

struct RecruitmentDetailsView: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            ProgressView()
                .controlSize(.large)
                .navigationTitle("求人の詳細")
                .toolbarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                        }
                    }
                }
        }
    }
}

#Preview {
    NavigationStack {
        RecruitmentDetailsView()
    }
}
