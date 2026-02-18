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
                colors: [Color(.systemGroupedBackground), Color.white],
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
                            .glassEffect(
                                .regular
                                    .tint(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .clear : .accentColor)
                                    .interactive(),
                                in: Circle()
                            )
                    }
                    .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .frame(width: UIScreen.main.bounds.width * 0.92)
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
                                        Image(systemName: " ")
                                            .resizable()
                                            .frame(width: 60, height: 60)
                                    @unknown default:
                                        EmptyView()
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
                otherUserProfile = ConversationUserProfile(uid: "other", fullName: "RDA Corporation", photoURL: nil)

                messages = [
                    ConversationMessage(
                        id: UUID().uuidString,
                        senderUID: "other",
                        text: "こんにちは。ご応募ありがとうございます。",
                        timestamp: Date().addingTimeInterval(-3600),
                        editedAt: nil,
                        isDeleted: false,
                        readByCount: 2,
                        senderDisplayName: "RDA",
                        senderIcon: nil
                    ),
                    ConversationMessage(
                        id: UUID().uuidString,
                        senderUID: currentUserUID,
                        text: "よろしくお願いします！",
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
                } else {
                    Text(message.text)
                        .font(.body)
                        .padding(12)
                        .background(isFromCurrentUser ? Color.accentColor.opacity(0.7) : Color(.systemGray5))
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

// MARK: - Type-erased shape helper

struct AnyShape: Shape {
    private let _path: (CGRect) -> Path

    init<S: Shape>(_ shape: S) {
        _path = { rect in shape.path(in: rect) }
    }

    func path(in rect: CGRect) -> Path {
        _path(rect)
    }
}

// MARK: - MessagesView (entry point used by ContentView)

struct MessagesView: View {
    var body: some View {
        MessagesChatView(
            conversation: ChatConversation(
                id: "default",
                participants: ["currentUser", "other"],
                createdAt: Date()
            ),
            currentUserUID: "currentUser"
        )
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
