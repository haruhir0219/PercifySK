import SwiftUI

@Observable
class JobStore {
    var cards: [Recruitment] = []
    var lastRemoved: Recruitment?
    var likeCount: Int = 0
    var skipCount: Int = 0
    
    /// Array of recruitment cards that were liked
    var likedJobs: [Recruitment] = []
    
    /// Array of recruitment cards that were skipped
    var skippedJobs: [Recruitment] = []
    
    /// History of all swipes with their order and action
    private var swipeHistory: [(recruitment: Recruitment, action: SwipeAction)] = []
    
    /// The initial number of cards when the store was first loaded
    private(set) var initialCardCount: Int = 0
    
    // MARK: - Computed Properties
    
    /// Returns true when all cards have been swiped away
    var isEmpty: Bool {
        cards.isEmpty
    }
    
    /// Returns the total number of cards currently in the deck
    var cardCount: Int {
        cards.count
    }
    
    /// Returns the total number of interactions (likes + skips)
    var totalInteractions: Int {
        likeCount + skipCount
    }
    
    /// Returns true if there's a card that can be undone
    var canUndo: Bool {
        lastRemoved != nil
    }
    
    /// Returns the progress percentage (0.0 to 1.0) of cards swiped
    var swipeProgress: Double {
        guard initialCardCount > 0 else { return 0.0 }
        let cardsViewed = initialCardCount - cards.count
        return Double(cardsViewed) / Double(initialCardCount)
    }
    
    /// Returns the progress as a percentage value (0 to 100)
    var swipeProgressPercentage: Double {
        swipeProgress * 100.0
    }
    
    init() {
        loadInitialData()
    }
    
    // MARK: - Data Management
    
    private func loadInitialData() {
        cards = [
            Recruitment(
                companyName: "Walt Disney Imagineering",
                companyLogo: "Disney",
                badgeText: "Percify特別選考",
                titleText: "WDIであなたの夢を世界中の人へ届けるために働いてみませんか",
                industryLeft: "Industry",
                industryRight: "ホスピタリティ",
                typeLeft: "Type",
                typeRight: "総合職",
                pay1Label: "Pay1",
                pay1Value: "990万円",
                pay2Label: "Pay2",
                pay2Value: "1270万円",
                tag1: "#海外勤務あり",
                tag2: "#外資系企業",
                tag3: "#英語必須",
                deadline: "あと29日",
                classification: "本選考",
                headerImageURL: URL(string: "https://i.pinimg.com/736x/7d/69/dc/7d69dc920959151e3825479f6c92b113.jpg")!,
                location: "Tokyo"
            ),
            Recruitment(
                companyName: "Citi Group",
                companyLogo: "Citi",
                badgeText: "Percify特別選考",
                titleText: "Citiグループで国際コンシューマーファイナンスに挑戦しよう",
                industryLeft: "Industry",
                industryRight: "金融",
                typeLeft: "Type",
                typeRight: "総合職",
                pay1Label: "Pay1",
                pay1Value: "550万円",
                pay2Label: "Pay2",
                pay2Value: "2240万円",
                tag1: "#国際展開",
                tag2: "#外資系企業",
                tag3: "#海外勤務あり",
                deadline: "あと66日",
                classification: "本選考",
                headerImageURL: URL(string: "https://www.bigdropinc.com/wp-content/uploads/2018/11/Citi-1920x1080.jpg")!,
                location: "Tokyo"
            ),
            Recruitment(
                companyName: "MHIエアロスペースシステムズ",
                companyLogo: "Mitsubishi",
                badgeText: "Percify特別選考",
                titleText: "MHIエアロスペースシステムズで宇宙工学の最先端へ挑戦する",
                industryLeft: "Industry",
                industryRight: "メーカー",
                typeLeft: "Type",
                typeRight: "総合職",
                pay1Label: "Pay1",
                pay1Value: "390万円",
                pay2Label: "Pay2",
                pay2Value: "1100万円",
                tag1: "#国内首位企業",
                tag2: "#海外勤務あり",
                tag3: "#選べる勤務地",
                deadline: "あと23日",
                classification: "本選考",
                headerImageURL: URL(string: "https://www.mhi.com/jp/group/masc/sites/g/files/jwhtju1961/files/styles/original_image/public/2024-08/space03.png?itok=oiVoipO8")!,
                location: "Tokyo"
            ),
            Recruitment(
                companyName: "アクセンチュア・ジャパン株式会社",
                companyLogo: "Accenture",
                badgeText: "Percify特別選考",
                titleText: "アクセンチュアで学生向けアプリの開発に携わろう",
                industryLeft: "Industry",
                industryRight: "コンサルティング",
                typeLeft: "Type",
                typeRight: "インターンシップ",
                pay1Label: "Pay1",
                pay1Value: "420万円",
                pay2Label: "Pay2",
                pay2Value: "1220万円",
                tag1: "#人気企業",
                tag2: "#コンサルティング",
                tag3: "#IT企業",
                deadline: "あと2日",
                classification: "インターン",
                headerImageURL: URL(string: "https://www.evolution-design.info/var/site/storage/images/evolution-design/image-galleries/about/news/accenture-office-on-silhstrasse-1/24561-1-eng-GB/accenture-office-on-silhstrasse-1_i1920.jpg")!,
                location: "Tokyo"
            ),
            Recruitment(
                companyName: "JPMorgan Chase",
                companyLogo: "JPMorgan",
                badgeText: "Percify特別選考",
                titleText: "JPMorgan Chaseのトレーディング部門で世界を舞台に活躍しませんか",
                industryLeft: "Industry",
                industryRight: "金融",
                typeLeft: "Type",
                typeRight: "新卒正社員",
                pay1Label: "Pay1",
                pay1Value: "550万円",
                pay2Label: "Pay2",
                pay2Value: "2280万円",
                tag1: "#海外勤務あり",
                tag2: "#世界を舞台に活躍",
                tag3: "#外資系企業",
                deadline: "あと22日",
                classification: "本選考",
                headerImageURL: URL(string: "https://arquitecturaviva.com/assets/uploads/obras/53847/av_218475.webp?h=c3137801")!,
                location: "New York Global Headquaters"
            ),
            Recruitment(
                companyName: "株式会社オリエンタルランド",
                companyLogo: "OLC",
                badgeText: "Percify特別選考",
                titleText: "新卒採用 - 株式会社オリエンタルランドで共に夢を紡ぐキャリア (IT・デジタルマネジメント)",
                industryLeft: "Industry",
                industryRight: "サービス",
                typeLeft: "Type",
                typeRight: "総合職",
                pay1Label: "Pay1",
                pay1Value: "320万円",
                pay2Label: "Pay2",
                pay2Value: "1540万円",
                tag1: "#海外勤務あり",
                tag2: "#福利厚生充実",
                tag3: "Percify特別選考",
                deadline: "あと13日",
                classification: "本選考",
                headerImageURL: URL(string: "https://world-of-disney.com/wp-content/uploads/2025/07/IMG_202306_063Pcrs.jpg")!,
                location: "出社"
            ),
            Recruitment(
                companyName: "伊藤忠株式会社",
                companyLogo: "Itochu",
                badgeText: "Percify特別選考",
                titleText: "伊藤忠株式会社の新規事業開拓チームでオセアニア鉄鉱石事業に携わる",
                industryLeft: "Industry",
                industryRight: "総合商社",
                typeLeft: "Type",
                typeRight: "総合職",
                pay1Label: "Pay1",
                pay1Value: "320万円",
                pay2Label: "Pay2",
                pay2Value: "1540万円",
                tag1: "#海外勤務あり",
                tag2: "#福利厚生充実",
                tag3: "#Percify特別選考",
                deadline: "あと92日",
                classification: "本選考",
                headerImageURL: URL(string: "https://www.itclogi.com/application/files/3817/4347/9132/image-crosstalk-01.jpg")!,
                location: "出社"
            )
        ]
        
        // Set the initial card count when data is first loaded
        initialCardCount = cards.count
    }
    
    // MARK: - Actions
    
    func handleLike(item: Recruitment) {
        likeCount += 1
        likedJobs.append(item)
        swipeHistory.append((recruitment: item, action: .like))
        removeCard(item, action: .like)
        // TODO: Hook up analytics or persistence for liked items
    }
    
    func handleDislike(item: Recruitment) {
        skipCount += 1
        skippedJobs.append(item)
        swipeHistory.append((recruitment: item, action: .dislike))
        removeCard(item, action: .dislike)
        // TODO: Hook up analytics or persistence for disliked items
    }
    
    func undoLastSwipe() {
        guard let removed = lastRemoved else { return }
        
        // Restore the card to the deck
        cards.append(removed)
        
        // Remove from swipe history
        if let lastHistoryIndex = swipeHistory.lastIndex(where: { $0.recruitment == removed }) {
            swipeHistory.remove(at: lastHistoryIndex)
        }
        
        // Decrement the appropriate counter and remove from liked/skipped arrays
        if let action = lastAction {
            switch action {
            case .like:
                likeCount = max(0, likeCount - 1)
                // Remove from liked jobs
                if let index = likedJobs.firstIndex(of: removed) {
                    likedJobs.remove(at: index)
                }
            case .dislike:
                skipCount = max(0, skipCount - 1)
                // Remove from skipped jobs
                if let index = skippedJobs.firstIndex(of: removed) {
                    skippedJobs.remove(at: index)
                }
            }
        }
        
        // Clear the undo state
        lastRemoved = nil
        lastAction = nil
    }
    
    /// Undo all swipes (both liked and skipped) and restore them to the deck in their original order
    func undoAllSwipes() {
        // Restore all cards back to the deck in reverse order of how they were swiped
        // This ensures the most recently swiped cards are on top
        let allSwipedCards = swipeHistory.reversed().map { $0.recruitment }
        cards.append(contentsOf: allSwipedCards)
        
        // Clear all counters and arrays
        likeCount = 0
        skipCount = 0
        likedJobs.removeAll()
        skippedJobs.removeAll()
        swipeHistory.removeAll()
        
        // Clear the undo state
        lastRemoved = nil
        lastAction = nil
    }
    
    // MARK: - Private Helpers
    
    private enum SwipeAction {
        case like, dislike
    }
    
    private var lastAction: SwipeAction?
    
    private func removeCard(_ item: Recruitment, action: SwipeAction) {
        if let idx = cards.firstIndex(of: item) {
            lastRemoved = cards.remove(at: idx)
            lastAction = action
        }
    }
    
    // MARK: - Optional: Data Loading Methods
    
    /// Call this to refresh data from a network source
    func refreshData() async {
        // TODO: Implement network call to fetch new recruitment data
        // For now, just reload the initial data
        await MainActor.run {
            loadInitialData()
        }
    }
    
    /// Add new cards to the deck
    func addCards(_ newCards: [Recruitment]) {
        cards.append(contentsOf: newCards)
        // Update initial count to include newly added cards
        initialCardCount = max(initialCardCount, cards.count)
    }
    
    /// Reset the store to initial state
    func reset() {
        cards.removeAll()
        lastRemoved = nil
        lastAction = nil
        likeCount = 0
        skipCount = 0
        likedJobs.removeAll()
        skippedJobs.removeAll()
        swipeHistory.removeAll()
        loadInitialData()
        // initialCardCount is set in loadInitialData()
    }
    
    /// Remove a job from the liked list
    func removeLikedJob(_ job: Recruitment) {
        if let index = likedJobs.firstIndex(of: job) {
            likedJobs.remove(at: index)
            likeCount = max(0, likeCount - 1)
            
            // Remove from swipe history
            if let historyIndex = swipeHistory.lastIndex(where: { $0.recruitment == job && $0.action == .like }) {
                swipeHistory.remove(at: historyIndex)
            }
        }
    }
    
    /// Remove a job from the skipped list
    func removeSkippedJob(_ job: Recruitment) {
        if let index = skippedJobs.firstIndex(of: job) {
            skippedJobs.remove(at: index)
            skipCount = max(0, skipCount - 1)
            
            // Remove from swipe history
            if let historyIndex = swipeHistory.lastIndex(where: { $0.recruitment == job && $0.action == .dislike }) {
                swipeHistory.remove(at: historyIndex)
            }
        }
    }
}
