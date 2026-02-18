//
//  MessageDetailsView.swift
//  Percify
//
//  Created by 松本知大 on 2025/12/05.
//

import SwiftUI

// MARK: - UI Models

struct ChatConversation {
    var id: String
    var participants: [String]
    var createdAt: Date
}

struct ConversationUserProfile {
    var uid: String
    var fullName: String
    var photoURL: String?
}

struct ConversationMessage: Identifiable, Equatable {
    var id: String
    var senderUID: String
    var text: String
    var timestamp: Date
    var editedAt: Date? = nil
    var isDeleted: Bool = false
    var readByCount: Int = 1
    var senderDisplayName: String? = nil
    var senderIcon: String? = nil
    var inlineRecruitmentCard: Recruitment? = nil
}

// MARK: - Messages Chat View

struct MessagesChatView: View {
    let conversation: ChatConversation
    let currentUserUID: String

    @Environment(\.dismiss) private var dismiss
    @FocusState private var isTextFieldFocused: Bool

    @State private var messages: [ConversationMessage] = []
    @State private var messageText: String = ""
    @State private var editingMessageID: String? = nil

    @State private var otherUserProfile: ConversationUserProfile? = nil
    @State private var isMuted: Bool = false
    @State private var showingCertifiedPopover: Bool = false

    @State private var keyboardHeight: CGFloat = 0
    @State private var scrollProxy: ScrollViewProxy?
    @State private var hasScrolledToBottom = false

    init(conversation: ChatConversation, currentUserUID: String) {
        self.conversation = conversation
        self.currentUserUID = currentUserUID
    }

    // MARK: Timestamp & spacing helpers

    private func shouldShowTimestampForMessage(at index: Int) -> Bool {
        guard index < messages.count else { return true }

        let current = messages[index]

        if index == messages.count - 1 { return true }
        if index == 0 { return true }

        let previous = messages[index - 1]

        if current.senderUID != previous.senderUID { return true }

        let delta = current.timestamp.timeIntervalSince(previous.timestamp)
        return delta > 60
    }

    private func spacingForMessage(at index: Int) -> CGFloat {
        guard index < messages.count && index > 0 else { return 12 }

        let current = messages[index]
        let previous = messages[index - 1]

        let isSameSender = current.senderUID == previous.senderUID
        let delta = current.timestamp.timeIntervalSince(previous.timestamp)
        let isWithinOneMinute = delta <= 60

        return (isSameSender && isWithinOneMinute) ? 4 : 12
    }

    @ViewBuilder
    private func messageBubbleContent(for message: ConversationMessage, at index: Int) -> some View {
        let showTimestamp = shouldShowTimestampForMessage(at: index)
        let bottomSpacing = spacingForMessage(at: index + 1)

        ConversationBubbleView(
            message: message,
            isFromCurrentUser: message.senderUID == currentUserUID,
            otherUserProfile: otherUserProfile,
            shouldShowTimestamp: showTimestamp,
            onEdit: {
                startEditing(message)
            },
            onUndoSend: {
                undoSend(message)
            }
        )
        .id(message.id)
        .padding(.bottom, bottomSpacing)
        .scrollTransition(.interactive(timingCurve: .easeInOut), axis: .vertical) { content, phase in
            content.scaleEffect(phase.isIdentity ? 1 : 0.95 + (0.05 * phase.value))
        }
    }

    private func scrollToBottomIfNeeded(proxy: ScrollViewProxy) {
        guard let last = messages.last else { return }

        if hasScrolledToBottom {
            withAnimation {
                proxy.scrollTo(last.id, anchor: .bottom)
            }
        } else {
            proxy.scrollTo(last.id, anchor: .bottom)
            hasScrolledToBottom = true
        }
    }

    // MARK: Computed properties

    private var senderDisplayName: String {
        if let custom = messages.first(where: { $0.senderUID != currentUserUID })?.senderDisplayName {
            return custom
        }
        return otherUserProfile?.fullName ?? "読み込み中"
    }

    private var senderIcon: String? {
        if let custom = messages.first(where: { $0.senderUID != currentUserUID })?.senderIcon {
            return custom
        }
        return otherUserProfile?.photoURL
    }

    // MARK: Actions

    private func startEditing(_ message: ConversationMessage) {
        guard !message.isDeleted else { return }
        editingMessageID = message.id
        messageText = message.text
        isTextFieldFocused = true
    }

    private func cancelEditing() {
        editingMessageID = nil
        messageText = ""
    }

    private func sendOrEditMessage() {
        let text = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        if let editingID = editingMessageID,
           let idx = messages.firstIndex(where: { $0.id == editingID }) {
            messages[idx].text = text
            messages[idx].editedAt = Date()
            editingMessageID = nil
        } else {
            let new = ConversationMessage(
                id: UUID().uuidString,
                senderUID: currentUserUID,
                text: text,
                timestamp: Date(),
                editedAt: nil,
                isDeleted: false,
                readByCount: 1
            )
            messages.append(new)
        }

        messageText = ""
    }

    private func undoSend(_ message: ConversationMessage) {
        guard let idx = messages.firstIndex(where: { $0.id == message.id }) else { return }
        messages[idx].isDeleted = true
    }

    // MARK: Body

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(Array(messages.enumerated()), id: \.element.id) { index, message in
                            messageBubbleContent(for: message, at: index)
                        }
                    }
                    .padding()
                }
                .scrollDismissesKeyboard(.interactively)
                .onChange(of: messages.count) { _, _ in
                    scrollToBottomIfNeeded(proxy: proxy)
                }
                .onChange(of: isTextFieldFocused) { _, focused in
                    if focused, let last = messages.last, hasScrolledToBottom {
                        withAnimation {
                            proxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                }
                .onAppear {
                    scrollProxy = proxy
                }
            }
        }
        .background(
            LinearGradient(
                colors: [Color.accentColor.opacity(0.2), Color(.systemBackground), Color(.systemBackground)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
        .safeAreaBar(edge: .bottom) {
            GlassEffectContainer {
                HStack {
                    TextField(
                        editingMessageID == nil ? "メッセージを入力" : "メッセージを編集",
                        text: $messageText,
                        axis: .vertical
                    )
                    .textFieldStyle(.plain)
                    .padding(10)
                    .padding(.leading, 4)
                    .glassEffect(.regular.interactive())
                    .focused($isTextFieldFocused)
                    .lineLimit(1...7)

                    if editingMessageID != nil {
                        Button {
                            cancelEditing()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.red)
                        }
                        .padding(10)
                        .glassEffect(.regular.interactive(), in: Circle())
                    }

                    Button {
                        let impact = UIImpactFeedbackGenerator(style: .rigid)
                        impact.impactOccurred()
                        sendOrEditMessage()
                        isTextFieldFocused = true
                    } label: {
                        Image(systemName: editingMessageID == nil ? "arrow.up" : "checkmark")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .gray : .black)
                            .padding(.all, 10)
                            .glassEffect(.regular.tint(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .clear : .accentColor)
                                    .interactive(),
                                in: Circle()
                            )
                    }
                    .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 16)
            .padding(.bottom, keyboardHeight == 0 ? 0 : 10)
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                ZStack {
                    Button {
                        showingCertifiedPopover = true
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundStyle(.secondary)
                                .padding(.leading, -4)
                            Text(senderDisplayName.prefix(10))
                                .font(.headline)
                            Text("...")
                                .font(.headline)
                                .padding(.leading, -6)
                        }
                        .padding(.all, 6.5)
                        .padding(.horizontal, 6)
                        .glassEffect(.regular.interactive())
                    }
                    .buttonStyle(.plain)
                    .popover(isPresented: $showingCertifiedPopover) {
                        VStack(spacing: 8) {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.title)
                                .foregroundStyle(.blue)
                            Text(senderDisplayName)
                                .font(.headline)
                            Text("認証されたビジネスです。")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .padding()
                        .presentationCompactAdaptation(.popover)
                    }
                    .offset(y: 54)

                    Button(action: {}) {
                        ZStack {
                            Circle()
                                .fill(Color(.systemGray5))
                                .frame(width: 60, height: 60)
                                .shimmering()
                                .clipShape(Circle())

                            if let iconURL = senderIcon, let url = URL(string: iconURL) {
                                AsyncImage(url: url) { phase in
                                    switch phase {
                                    case .empty:
                                        ProgressView()
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 60, height: 60)
                                            .clipShape(Circle())
                                    case .failure:
                                        Image("Solvvy")
                                            .resizable()
                                            .frame(width: 60, height: 60)
                                    @unknown default:
                                        Color.clear
                                    }
                                }
                            } else {
                                Image(systemName: " ")
                                    .resizable()
                                    .frame(width: 60, height: 60)
                            }
                        }
                        .shadow(color: .black.opacity(0.1), radius: 12)
                    }
                    .offset(y: 12)
                }
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button {
                        isMuted.toggle()
                    } label: {
                        Label(isMuted ? "ミュートを解除" : "ミュート", systemImage: isMuted ? "speaker.wave.2" : "speaker.slash")
                    }

                    Divider()

                    Button(role: .destructive) {
                        // UI-only: block action placeholder
                    } label: {
                        Label("ブロック", systemImage: "hand.raised")
                    }

                    Button(role: .destructive) {
                        dismiss()
                    } label: {
                        Label("会話を削除", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                }
            }
        }
        .onAppear {
            if messages.isEmpty {
                otherUserProfile = ConversationUserProfile(uid: "other", fullName: "Solvvy株式会社 採用担当", photoURL: nil)

                messages = [
                    ConversationMessage(
                        id: UUID().uuidString,
                        senderUID: "other",
                        text: """
松本知大さま、こんにちは！
Solvvy株式会社吉丸でございます。

先日はPercify就活EXPOにてありがとうございました！
松本知大さまにとって有意義なお時間になっておりましたら幸いです。

EXPOでもお伝えしたコンサル選考対策セミナーに加え、
新たに役員＆新卒入社社員と話せるポジション別説明会を開催いたします！ぜひご参加ください！
""",
                        timestamp: Date().addingTimeInterval(-3600),
                        editedAt: nil,
                        isDeleted: false,
                        readByCount: 2,
                        senderDisplayName: "Solvvy株式会社",
                        senderIcon: nil
                    ),
                    ConversationMessage(
                        id: UUID().uuidString,
                        senderUID: "other",
                        text: "",
                        timestamp: Date().addingTimeInterval(-3480),
                        editedAt: nil,
                        isDeleted: false,
                        readByCount: 2,
                        senderDisplayName: "Solvvy株式会社",
                        senderIcon: nil,
                        inlineRecruitmentCard: Recruitment(
                            companyName: "Solvvy株式会社",
                            companyLogo: "Solvvy",
                            badgeText: "Percify特別選考",
                            titleText: "コンサル志望学生向け: 【金融×IT】を学べる3DAYインターン",
                            industryLeft: "Industry",
                            industryRight: "コンサルティング・金融",
                            typeLeft: "Type",
                            typeRight: "インターン",
                            pay1Label: "Pay1",
                            pay1Value: "320",
                            pay2Label: "Pay2",
                            pay2Value: "1120",
                            tag1: "#上場企業",
                            tag2: "#福利厚生充実",
                            tag3: "#Percify特別選考",
                            deadline: "あと14日",
                            classification: "インターン",
                            headerImageURL: URL(string: "https://paiza-webapp.s3.ap-northeast-1.amazonaws.com/recruiter/5427/photo_top/large-3e64bc594b80bd45570a4fb1667eef8f.jpg")!,
                            location: "出社"
                        )
                    ),
                    ConversationMessage(
                        id: UUID().uuidString,
                        senderUID: currentUserUID,
                        text: "はい、参加を希望します。",
                        timestamp: Date().addingTimeInterval(-3500),
                        editedAt: nil,
                        isDeleted: false,
                        readByCount: 1
                    )
                ]
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { notification in
            if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                keyboardHeight = keyboardFrame.height

                if let proxy = scrollProxy, let last = messages.last, hasScrolledToBottom {
                    withAnimation(.easeOut(duration: 0.25)) {
                        proxy.scrollTo(last.id, anchor: .bottom)
                    }
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            keyboardHeight = 0
        }
    }
}

// MARK: - Message Details View (entry point used by MessagesView)

struct MessageDetailsView: View {
    let chat: Chat
    var onDecline: (() -> Void)?

    var body: some View {
        MessagesChatView(
            conversation: ChatConversation(
                id: chat.id.uuidString,
                participants: ["currentUser", "other"],
                createdAt: Date()
            ),
            currentUserUID: "currentUser"
        )
    }
}

// MARK: - Conversation Bubble View

struct ConversationBubbleView: View {
    let message: ConversationMessage
    let isFromCurrentUser: Bool
    let otherUserProfile: ConversationUserProfile?
    let shouldShowTimestamp: Bool
    let onEdit: () -> Void
    let onUndoSend: () -> Void

    @State private var isSingleLine = false

    private var canEdit: Bool {
        isFromCurrentUser && !message.isDeleted && message.timestamp.timeIntervalSinceNow > -900
    }

    private var canUndoSend: Bool {
        isFromCurrentUser && !message.isDeleted
    }

    var body: some View {
        HStack {
            if isFromCurrentUser {
                Spacer(minLength: 60)
            }

            VStack(alignment: isFromCurrentUser ? .trailing : .leading, spacing: 4) {
                if !isFromCurrentUser, let profile = otherUserProfile {
                    Text(profile.fullName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                if message.isDeleted {
                    Text("このメッセージは削除されました")
                        .font(.body)
                        .italic()
                        .foregroundColor(.secondary)
                        .padding(12)
                        .background(Color(.systemGray5))
                        .cornerRadius(100)
                } else if !message.text.isEmpty {
                    Text(message.text)
                        .font(.body)
                        .padding(12)
                        .background(isFromCurrentUser ? Color.accentColor.opacity(0.5) : Color(.systemGray5))
                        .foregroundColor(.primary)
                        .clipShape(isSingleLine ? AnyShape(Capsule()) : AnyShape(RoundedRectangle(cornerRadius: 18)))
                        .background(
                            GeometryReader { geometry in
                                Color.clear
                                    .onAppear {
                                        isSingleLine = geometry.size.height <= 44
                                    }
                            }
                        )
                        .contextMenu {
                            Button {
                                UIPasteboard.general.string = message.text
                            } label: {
                                Label("コピー", systemImage: "doc.on.doc")
                            }

                            if canEdit {
                                Button {
                                    onEdit()
                                } label: {
                                    Label("編集", systemImage: "pencil")
                                }
                            }

                            if canUndoSend {
                                Button(role: .destructive) {
                                    onUndoSend()
                                } label: {
                                    Label("送信を取り消す", systemImage: "arrow.uturn.backward")
                                }
                            }
                        }
                }

                if let recruitment = message.inlineRecruitmentCard {
                    InlineRecruitmentCardView(recruitment: recruitment)
                        .frame(maxWidth: 280)
                }

                if shouldShowTimestamp {
                    HStack(spacing: 4) {
                        Text(message.timestamp, style: .time)
                            .font(.caption2)
                            .foregroundColor(.secondary)

                        if message.editedAt != nil {
                            Text("編集済み")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }

                        if isFromCurrentUser && !message.isDeleted {
                            Text(message.readByCount > 1 ? "既読" : "配信済み")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }

            if !isFromCurrentUser {
                Spacer(minLength: 60)
            }
        }
    }
}

// MARK: - Inline Recruitment Card View

struct InlineRecruitmentCardView: View {
    let recruitment: Recruitment

    @State private var imageOpacity: Double = 0
    @State private var showDetails = false
    @Namespace private var transition

    var body: some View {
        Button {
            showDetails = true
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                // Header image
                ZStack(alignment: .topTrailing) {
                    AsyncImage(url: recruitment.headerImageURL) { phase in
                        switch phase {
                        case .empty:
                            Color(.systemGray5)
                                .shimmering()
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .opacity(imageOpacity)
                                .onAppear {
                                    withAnimation(.easeIn(duration: 0.3)) {
                                        imageOpacity = 1
                                    }
                                }
                        case .failure:
                            Color(.systemGray5)
                        @unknown default:
                            Color.clear
                        }
                    }
                    .frame(height: 110)
                    .clipped()

                    // Badge
                    HStack(spacing: 4) {
                        Image("LogoSmall")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 12, height: 15)
                        Text(recruitment.badgeText)
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .lineLimit(1)
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color.purple)
                            .overlay(Capsule().strokeBorder(Color.white.opacity(0.3), lineWidth: 0.5))
                    )
                    .padding(8)
                }

                // Card details
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 10) {
                        Image(recruitment.companyLogo)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 36, height: 36)
                            .clipShape(Circle())
                            .overlay(Circle().strokeBorder(Color(.systemGray4), lineWidth: 0.5))

                        VStack(alignment: .leading, spacing: 1) {
                            Text(recruitment.titleText)
                                .font(.footnote)
                                .fontWeight(.semibold)
                                .foregroundStyle(.primary)
                                .lineLimit(2)
                            Text(recruitment.companyName)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                    }

                    Divider()

                    HStack(spacing: 0) {
                        VStack(alignment: .leading, spacing: 1) {
                            Text("新卒年収")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            HStack(alignment: .bottom, spacing: 1) {
                                Text(recruitment.pay1Value)
                                    .font(.subheadline)
                                    .fontWeight(.heavy)
                                Text("万円")
                                    .font(.caption2)
                                    .fontWeight(.semibold)
                                    .padding(.bottom, 1)
                            }
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 1) {
                            Text("30歳年収")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            HStack(alignment: .bottom, spacing: 1) {
                                Text(recruitment.pay2Value)
                                    .font(.subheadline)
                                    .fontWeight(.heavy)
                                Text("万円")
                                    .font(.caption2)
                                    .fontWeight(.semibold)
                                    .padding(.bottom, 1)
                            }
                        }
                        Spacer()
                        Text(recruitment.classification)
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundColor(.accentColor)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Capsule().fill(.thinMaterial))
                    }

                    HStack(spacing: 6) {
                        ForEach([recruitment.tag1, recruitment.tag2, recruitment.tag3], id: \.self) { tag in
                            Text(tag)
                                .font(.caption2)
                                .lineLimit(1)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Capsule().fill(Color(.systemGray6)))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(10)
                .background(Color(.systemBackground))

                // Entry button
                Button {
                    showDetails = true
                } label: {
                    Text("エントリー")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            LinearGradient(
                                colors: [Color.accentColor, Color.accentColor.opacity(0.9)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .buttonStyle(.plain)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(Color(.systemGray4), lineWidth: 0.5)
        )
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
        .matchedTransitionSource(id: "inlineCard_\(recruitment.id)", in: transition)
        .fullScreenCover(isPresented: $showDetails) {
            EventDetailsView(
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
            .navigationTransition(.zoom(sourceID: "inlineCard_\(recruitment.id)", in: transition))
        }
    }
}

// MARK: - Type-erased shape helper

struct AnyShape: Shape {
    private let _path: @Sendable (CGRect) -> Path

    init<S: Shape>(_ shape: S) {
        _path = { rect in shape.path(in: rect) }
    }

    func path(in rect: CGRect) -> Path {
        _path(rect)
    }
}

#Preview {
    NavigationStack {
        MessagesChatView(
            conversation: ChatConversation(
                id: "preview",
                participants: ["user1", "user2"],
                createdAt: Date()
            ),
            currentUserUID: "user1"
        )
    }
}
