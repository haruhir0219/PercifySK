//
//  MessagesArchivedView.swift
//  Percify
//
//  Created by Assistant on 2025/12/16.
//

import SwiftUI

struct MessagesArchivedView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var chatStore: ChatStore
    
    var body: some View {
        NavigationStack {
            ScrollView {
            LazyVStack(spacing: 0) {
                if chatStore.declinedChats.isEmpty {
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    ContentUnavailableView(
                        "アーカイブされたメッセージはありません",
                        systemImage: "archivebox",
                        description: Text("承諾しなかったスカウトがここに表示されます。")
                    )
                    Spacer()
                    //.padding(.top, 100)
                } else {
                    ForEach(chatStore.declinedChats) { chat in
                        VStack(spacing: 0) {
                            ArchivedChatRowView(chat: chat) {
                                // Restore action
                                withAnimation {
                                    chatStore.restoreChat(chat)
                                }
                            } onDelete: {
                                // Delete action
                                withAnimation {
                                    chatStore.deleteChat(chat)
                                }
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            
                            if chat.id != chatStore.declinedChats.last?.id {
                                Divider()
                                    .padding(.leading, 88)
                            }
                        }
                    }
                }
            }
            .padding(.top, 8)
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
            .padding(.all, -50)
            .ignoresSafeArea()
        )
        .navigationTitle("アーカイブ")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("完了") {
                    dismiss()
                }
            }
        }
        }
    }
}

// MARK: - Archived Chat Row View

struct ArchivedChatRowView: View {
    let chat: Chat
    let onRestore: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            // Chat content
            HStack(alignment: .top, spacing: 26) {
                // Spacer for logo
                Color.clear
                    .frame(width: 60, height: 60)
                
                VStack(alignment: .leading, spacing: 4) {
                    // Company name with badge
                    HStack(alignment: .center, spacing: 8) {
                        Text(chat.companyName)
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                        
                        Spacer()
                        
                        // Declined date
                        if let declinedDate = chat.declinedDate {
                            Text(declinedDate, style: .relative)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Message preview
                    Text(chat.messagePreview)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                    
                    // Action buttons
                    HStack(spacing: 12) {
                        Button(action: onRestore) {
                            Label("復元", systemImage: "arrow.uturn.backward")
                                .font(.caption)
                                .foregroundColor(.accentColor)
                        }
                        .buttonStyle(.bordered)
                        
                        Button(role: .destructive, action: onDelete) {
                            Label("削除", systemImage: "trash")
                                .font(.caption)
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding(.top, 8)
                }
            }
            .padding(.vertical, 14)
            .contentShape(Rectangle())
            
            // Company Logo (grayed out)
            ZStack {
                Circle()
                    .fill(Color(.systemBackground))
                
                Image(chat.companyLogo)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                    .opacity(0.5)
            }
            .frame(width: 60, height: 60)
            .padding(3)
            .background(
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 2)
            )
            .overlay(
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.red)
                    .background(Circle().fill(Color.white))
                    .offset(x: 20, y: -5)
            )
            .offset(y: 8)
        }
    }
}

#Preview {
    NavigationStack {
        MessagesArchivedView(chatStore: ChatStore())
    }
}
