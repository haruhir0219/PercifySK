//
//  MessageDetailsView.swift
//  Percify
//
//  Created by 松本知大 on 2025/12/05.
//

import SwiftUI

// MARK: - Message Model
struct ChatMessage: Identifiable, Codable {
    let id: UUID
    let text: String
    let isFromCurrentUser: Bool
    let timestamp: Date
    
    init(id: UUID = UUID(), text: String, isFromCurrentUser: Bool, timestamp: Date = Date()) {
        self.id = id
        self.text = text
        self.isFromCurrentUser = isFromCurrentUser
        self.timestamp = timestamp
    }
}

// MARK: - Message Storage Manager
@Observable
class MessageStorage {
    var messages: [ChatMessage] = []
    var isAccepted: Bool = false
    
    private let storageKey = "saved_messages"
    private let acceptanceKey = "scout_accepted"
    
    init() {
        loadMessages()
        loadAcceptanceStatus()
        
        // Add placeholder messages if empty
        if messages.isEmpty {
            addPlaceholderMessages()
        }
    }
    
    func addPlaceholderMessages() {
        let message1 = ChatMessage(
            text: """
            松本 様
            
            突然のご連絡を差し上げますこと、失礼いたします。
            伊藤忠商事株式会社 航空機リース事業部の□□と申します。
            
            この度、当社における将来的な人材採用に向けて、航空機関連ビジネス・アセットファイナンス領域における高度な専門性・ポテンシャルをお持ちの方を幅広くリサーチさせていただいております。
            その中で、松本様のご経歴・ご関心領域を拝見し、当部門において求めております将来のグローバル人材像に極めて高い親和性があると判断し、ご挨拶を兼ねてご連絡させていただいた次第です。
            
            当社航空機リース事業は、航空会社・金融機関・投資家との国際的な取引を通じて、航空機の購入・売却、オペレーティングリース・ファイナンスリース、資産価値分析、リスクマネジメント等、多岐にわたる業務を行っております。特に、昨今の航空需要の回復と新機材へのリプレース需要に伴い、市場の動向は複雑さとスピードを増しており、従来以上に高度な分析力、語学力、交渉力、そして柔軟な思考が求められています。
            
            松本様がこれまでに培われてきたスキルセットや国際的な視点、また学問的バックグラウンドは、当部門の取り組む事業領域との整合性が高く、今後の航空金融分野において大きく活躍いただける素養をお持ちであると感じております。
            """,
            isFromCurrentUser: false,
            timestamp: Date().addingTimeInterval(-3600)
        )
        
        let message2 = ChatMessage(
            text: """
            もちろん、現時点で正式な選考への参加をお願いするものではなく、あくまでも当社事業およびキャリアパスのご紹介が目的でございます。もしご関心をお持ちいただけましたら、
            ・事業概要のご説明
            ・キャリア形成の方向性
            ・若手社員の業務内容
            などをお伝えするオンライン形式でのカジュアルミーティングを設定させていただければ幸いです。
            
            ご多用のところ恐れ入りますが、ご興味をお持ちいただけましたら、可能なお日にちを数候補お知らせください。日程は柔軟に調整させていただきます。
            
            末筆ながら、松本様の今後のさらなるご活躍を心よりお祈り申し上げるとともに、少しでもお話しする機会を頂戴できますと幸いです。
            
            何卒よろしくお願い申し上げます。
            
            伊藤忠商事株式会社
            人事部　採用係
            """,
            isFromCurrentUser: false,
            timestamp: Date().addingTimeInterval(-3500)
        )
        
        messages = [message1, message2]
        saveMessages()
    }
    
    func sendMessage(_ text: String) {
        let newMessage = ChatMessage(text: text, isFromCurrentUser: true)
        messages.append(newMessage)
        saveMessages()
    }
    
    func acceptScout() {
        isAccepted = true
        saveAcceptanceStatus()
    }
    
    func resetDemo() {
        messages.removeAll()
        isAccepted = false
        addPlaceholderMessages()
        saveAcceptanceStatus()
    }
    
    private func saveMessages() {
        if let encoded = try? JSONEncoder().encode(messages) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }
    
    private func loadMessages() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([ChatMessage].self, from: data) {
            messages = decoded
        }
    }
    
    private func saveAcceptanceStatus() {
        UserDefaults.standard.set(isAccepted, forKey: acceptanceKey)
    }
    
    private func loadAcceptanceStatus() {
        isAccepted = UserDefaults.standard.bool(forKey: acceptanceKey)
    }
}

// MARK: - Message Bubble View
struct MessageBubble: View {
    let message: ChatMessage
    let previousMessage: ChatMessage?
    let isLastMessage: Bool
    
    // Check if this message is within 1 minute of the previous message from the same sender
    private var shouldShowTimestamp: Bool {
        // Always show timestamp for the last message
        if isLastMessage { return true }
        
        guard let previous = previousMessage else { return true }
        guard previous.isFromCurrentUser == message.isFromCurrentUser else { return true }
        
        let timeDifference = message.timestamp.timeIntervalSince(previous.timestamp)
        return timeDifference >= 60 // 60 seconds = 1 minute
    }
    
    private var shouldShowAvatar: Bool {
        guard let previous = previousMessage else { return true }
        guard previous.isFromCurrentUser == message.isFromCurrentUser else { return true }
        
        let timeDifference = message.timestamp.timeIntervalSince(previous.timestamp)
        return timeDifference >= 60
    }
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            // Profile picture for sender (left side)
            if !message.isFromCurrentUser {
                if shouldShowAvatar {
                    Image("Itochu")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color(.systemGray4), lineWidth: 0.5)
                        )
                } else {
                    // Spacer to maintain alignment when avatar is hidden
                    Color.clear
                        .frame(width: 40, height: 40)
                }
            }
            
            if message.isFromCurrentUser {
                Spacer()
            }
            
            VStack(alignment: message.isFromCurrentUser ? .trailing : .leading, spacing: 4) {
                Text(message.text)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .glassEffect(.clear.tint(message.isFromCurrentUser ? Color.accentColor : Color(.clear)), in: .rect(cornerRadius: 18))
                    //.background(message.isFromCurrentUser ? Color.accentColor : Color(.systemGray5))
                    .foregroundColor(message.isFromCurrentUser ? .white : .primary)
                    //.clipShape(RoundedRectangle(cornerRadius: 18))
                
                if shouldShowTimestamp {
                    Text(message.timestamp, style: .time)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 4)
                }
            }
            .frame(maxWidth: 280, alignment: message.isFromCurrentUser ? .trailing : .leading)
            
            if !message.isFromCurrentUser {
                Spacer()
            }
        }
    }
}

// MARK: - Main Message Details View
struct MessageDetailsView: View {
    let chat: Chat
    @State private var messageStorage = MessageStorage()
    @State private var messageText = ""
    @State private var showTextField = false
    @State private var showResetDialog = false
    @FocusState private var isTextFieldFocused: Bool
    @Environment(\.dismiss) private var dismiss
    
    // Add access to ChatStore to handle decline
    var onDecline: (() -> Void)?
    
    var body: some View {
        VStack(spacing: 0) {
            // Messages List
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(Array(messageStorage.messages.enumerated()), id: \.element.id) { index, message in
                            let previousMessage = index > 0 ? messageStorage.messages[index - 1] : nil
                            let isLastMessage = index == messageStorage.messages.count - 1
                            let shouldReduceSpacing = previousMessage != nil && 
                                                     previousMessage!.isFromCurrentUser == message.isFromCurrentUser &&
                                                     message.timestamp.timeIntervalSince(previousMessage!.timestamp) < 60
                            
                            MessageBubble(message: message, previousMessage: previousMessage, isLastMessage: isLastMessage)
                                .id(message.id)
                                .padding(.top, shouldReduceSpacing ? 4 : 12)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    //.padding(.bottom, -30)
                    .scrollTransition(
                                                .interactive(timingCurve: .easeInOut),
                                                axis: .vertical
                                            ) { content, phase  in
                                                let scaledContent = content.scaleEffect(phase.isIdentity ? 1 : 0.95 + (0.05 * phase.value))
                                                
                                                return scaledContent
                                            }
                }
                .onChange(of: messageStorage.messages.count) { _, _ in
                    if let lastMessage = messageStorage.messages.last {
                        withAnimation {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
                .onAppear {
                    // Restore showTextField state based on acceptance status
                    showTextField = messageStorage.isAccepted
                    
                    // Scroll to bottom after a brief delay to ensure layout is complete
                    if let lastMessage = messageStorage.messages.last {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
                .overlay {
                    if !showTextField {
                        ZStack {
                            Rectangle()
                                .fill(.ultraThinMaterial)
                                .allowsHitTesting(true)
                                .transition(.opacity)
                                .ignoresSafeArea()
                            Text("スカウトを承諾して\nメッセージを確認")
                                .font(.title)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                }
            }
            
            // Message Input Bar (only shown after TEMPLATE button is tapped)
            if showTextField {
                HStack(spacing: 12) {
                    // Text Field
                    TextField("メッセージを入力...", text: $messageText, axis: .vertical)
                        .textFieldStyle(.plain)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .focused($isTextFieldFocused)
                        .lineLimit(1...5)
                    
                    // Send Button
                    Button(action: sendMessage) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(messageText.isEmpty ? .gray : .accentColor)
                    }
                    .disabled(messageText.isEmpty)
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color(.systemBackground))
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.accentColor.opacity(0.2), Color.white, Color.white]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
        //.navigationTitle(chat.companyName)
        //.navigationBarTitleDisplayMode(.inline)
        .safeAreaBar(edge: .bottom) {
            if !showTextField {
                HStack(spacing: -20) {
                    Button(action: {
                        // Call the decline callback
                        onDecline?()
                        
                        // Haptic feedback
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        
                        // Dismiss the view
                        dismiss()
                    }) {
                        Text("承諾しない")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                    }
                    .buttonStyle(.glass)
                    .padding(.horizontal)
                    Button(action: {
                        // Play success haptic feedback
                        UINotificationFeedbackGenerator().notificationOccurred(.success)
                        
                        // Save acceptance status
                        messageStorage.acceptScout()
                        
                        withAnimation {
                            showTextField = true
                        }
                    }) {
                        Text("スカウトを承諾")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                    }
                    .buttonStyle(.glassProminent)
                    .padding(.horizontal)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                ZStack {
                    HStack(spacing: 4) {
                        Text(chat.companyName)
                            .font(.headline)
                        Image(systemName: "chevron.compact.right")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundStyle(.secondary)
                    }
                        .padding(.all, 8)
                        .padding(.horizontal, 6)
                        .glassEffect(.regular.interactive())
                        .offset(y: 55)
                    Button(action: { }) {
                        Image("Itochu")
                            .resizable()
                            .frame(width: 70, height: 70)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.1), radius: 12)
                    }
                    .offset(y: 12)
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    showResetDialog = true
                }) {
                    Image(systemName: "ellipsis")
                }
            }
        }
        .confirmationDialog("", isPresented: $showResetDialog) {
            Button("デモをリセット", role: .destructive) {
                withAnimation {
                    showTextField = false
                    messageStorage.resetDemo()
                }
            }
            Button("キャンセル", role: .cancel) {}
        }
    }
    
    private func sendMessage() {
        let trimmedText = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }
        
        messageStorage.sendMessage(trimmedText)
        messageText = ""
    }
}

#Preview {
    NavigationStack {
        MessageDetailsView(chat: Chat(
            companyName: "伊藤忠商事株式会社",
            companyLogo: "Itochu",
            badge: .priority,
            messagePreview: "松本さん、ぜひ弊社の航空機リース事業部で世界を舞台に活躍しませんか？",
            timestamp: "火曜日",
            isUnread: true,
            isPriority: true
        ))
    }
}
