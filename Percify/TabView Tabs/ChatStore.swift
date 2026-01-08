import SwiftUI

struct Chat: Identifiable, Equatable, Codable {
    let id: UUID
    let companyName: String
    let companyLogo: String
    let badge: ChatBadge?
    let messagePreview: String
    let timestamp: String
    var isUnread: Bool
    let isPriority: Bool
    var isDeclined: Bool // Track if user declined the scout
    var declinedDate: Date? // When the scout was declined
    
    init(id: UUID = UUID(), companyName: String, companyLogo: String, badge: ChatBadge?, messagePreview: String, timestamp: String, isUnread: Bool, isPriority: Bool, isDeclined: Bool = false, declinedDate: Date? = nil) {
        self.id = id
        self.companyName = companyName
        self.companyLogo = companyLogo
        self.badge = badge
        self.messagePreview = messagePreview
        self.timestamp = timestamp
        self.isUnread = isUnread
        self.isPriority = isPriority
        self.isDeclined = isDeclined
        self.declinedDate = declinedDate
    }
    
    enum ChatBadge: String, Codable {
        case priority = "Percify特別選考"
        case standard = "総合商社"
    }
}

@Observable
class ChatStore {
    var chats: [Chat] = []
    
    private let storageKey = "saved_chats"
    
    // MARK: - Computed Properties
    
    /// Returns all active (non-declined) chats
    var activeChats: [Chat] {
        chats.filter { !$0.isDeclined }
    }
    
    /// Returns all declined/archived chats
    var declinedChats: [Chat] {
        chats.filter { $0.isDeclined }
    }
    
    /// Returns all priority chats
    var priorityChats: [Chat] {
        chats.filter { $0.isPriority }
    }
    
    /// Returns all standard chats
    var standardChats: [Chat] {
        chats.filter { !$0.isPriority }
    }
    
    /// Returns the total number of unread chats
    var unreadCount: Int {
        chats.filter { $0.isUnread }.count
    }
    
    /// Returns the total number of declined chats
    var declinedCount: Int {
        declinedChats.count
    }
    
    init() {
        loadChats()
        if chats.isEmpty {
            loadInitialData()
        }
    }
    
    // MARK: - Data Management
    
    private func loadInitialData() {
        chats = [
            // Priority Chats
            Chat(
                companyName: "伊藤忠商事株式会社",
                companyLogo: "Itochu",
                badge: .priority,
                messagePreview: "松本さん、ぜひ弊社の航空機リース事業部で世界を舞台に活躍しませんか？このスカウトをタップして…",
                timestamp: "火曜日",
                isUnread: true,
                isPriority: true
            ),
            Chat(
                companyName: "三菱商事株式会社",
                companyLogo: "Mitsubishi",
                badge: .priority,
                messagePreview: "松本さん、三菱商事のエネルギー部門で新しいキャリアを始めませんか？",
                timestamp: "月曜日",
                isUnread: false,
                isPriority: true
            ),
            Chat(
                companyName: "丸紅株式会社",
                companyLogo: "Marubeni",
                badge: .priority,
                messagePreview: "海外駐在のチャンスあり！グローバルに活躍できるポジションをご用意しています",
                timestamp: "日曜日",
                isUnread: true,
                isPriority: true
            ),
            
            // Standard Chats
            Chat(
                companyName: "伊藤忠商事株式会社",
                companyLogo: "Itochu",
                badge: .standard,
                messagePreview: "松本さん、ぜひ弊社の航空機リース事業部で世界を舞台に活躍しませんか？このスカウトをタップして…",
                timestamp: "火曜日",
                isUnread: true,
                isPriority: false
            ),
            Chat(
                companyName: "三井物産株式会社",
                companyLogo: "Mitsui",
                badge: .standard,
                messagePreview: "グローバルビジネスに興味はありませんか？",
                timestamp: "月曜日",
                isUnread: false,
                isPriority: false
            ),
            Chat(
                companyName: "住友商事株式会社",
                companyLogo: "Sumitomo",
                badge: .standard,
                messagePreview: "新卒採用の説明会にご招待します",
                timestamp: "土曜日",
                isUnread: true,
                isPriority: false
            ),
            Chat(
                companyName: "三井物産株式会社",
                companyLogo: "Mitsui",
                badge: .standard,
                messagePreview: "グローバルビジネスに興味はありませんか？",
                timestamp: "月曜日",
                isUnread: false,
                isPriority: false
            ),
            Chat(
                companyName: "住友商事株式会社",
                companyLogo: "Sumitomo",
                badge: .standard,
                messagePreview: "新卒採用の説明会にご招待します",
                timestamp: "土曜日",
                isUnread: true,
                isPriority: false
            ),
            Chat(
                companyName: "双日株式会社",
                companyLogo: "Sojitz",
                badge: .standard,
                messagePreview: "インターンシップのご案内です",
                timestamp: "金曜日",
                isUnread: false,
                isPriority: false
                ),
            Chat(
                companyName: "双日株式会社",
                companyLogo: "Sojitz",
                badge: .standard,
                messagePreview: "インターンシップのご案内です",
                timestamp: "金曜日",
                isUnread: false,
                isPriority: false
            )
        ]
    }
    
    // MARK: - Actions
    
    /// Mark a chat as read
    func markAsRead(_ chat: Chat) {
        if let index = chats.firstIndex(where: { $0.id == chat.id }) {
            chats[index].isUnread = false
            saveChats()
        }
    }
    
    /// Decline a chat (move to archived)
    func declineChat(_ chat: Chat) {
        if let index = chats.firstIndex(where: { $0.id == chat.id }) {
            chats[index].isDeclined = true
            chats[index].declinedDate = Date()
            saveChats()
        }
    }
    
    /// Restore a declined chat
    func restoreChat(_ chat: Chat) {
        if let index = chats.firstIndex(where: { $0.id == chat.id }) {
            chats[index].isDeclined = false
            chats[index].declinedDate = nil
            saveChats()
        }
    }
    
    /// Delete a chat
    func deleteChat(_ chat: Chat) {
        chats.removeAll { $0.id == chat.id }
        saveChats()
    }
    
    // MARK: - Persistence
    
    private func saveChats() {
        if let encoded = try? JSONEncoder().encode(chats) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }
    
    private func loadChats() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([Chat].self, from: data) {
            chats = decoded
        }
    }
    
    // MARK: - Optional: Data Loading Methods
    
    /// Call this to refresh data from a network source
    func refreshData() async {
        // TODO: Implement network call to fetch new chat data
        await MainActor.run {
            loadInitialData()
        }
    }
    
    /// Add new chats
    func addChats(_ newChats: [Chat]) {
        chats.append(contentsOf: newChats)
    }
    
    /// Reset the store to initial state
    func reset() {
        chats.removeAll()
        loadInitialData()
        saveChats()
    }
}
