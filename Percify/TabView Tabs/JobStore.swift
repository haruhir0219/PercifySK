import SwiftUI

@Observable
class JobStore {
    var cards: [Recruitment] = []
    var lastRemoved: Recruitment?
    var likeCount: Int = 0
    var skipCount: Int = 0
    
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
    
    init() {
        loadInitialData()
    }
    
    // MARK: - Data Management
    
    private func loadInitialData() {
        cards = [
            Recruitment(
                companyName: "Acme Corp",
                badgeText: "Hot",
                titleText: "iOS Engineer — SwiftUI & Concurrency",
                industryLeft: "Industry",
                industryRight: "FinTech",
                typeLeft: "Type",
                typeRight: "Full-time",
                pay1Label: "Pay1",
                pay1Value: "XX万円",
                pay2Label: "Pay2",
                pay2Value: "XX万円",
                tag1: "#SwiftUI",
                tag2: "#iOS",
                tag3: "#AsyncAwait",
                deadline: "20XX/1/31 (10Days)",
                classification: "インターン",
                headerImageURL: URL(string: "https://picsum.photos/465/300")!,
                location: "Tokyo"
            ),
            Recruitment(
                companyName: "Beta Labs",
                badgeText: "New",
                titleText: "Backend Developer — Distributed Systems",
                industryLeft: "Industry",
                industryRight: "SaaS",
                typeLeft: "Type",
                typeRight: "Remote",
                pay1Label: "Pay1",
                pay1Value: "XX万円",
                pay2Label: "Pay2",
                pay2Value: "XX万円",
                tag1: "#Kubernetes",
                tag2: "#Go",
                tag3: "#Cloud",
                deadline: "20XX/2/20 (15Days)",
                classification: "新卒採用",
                headerImageURL: URL(string: "https://picsum.photos/465/300")!,
                location: "Osaka"
            ),
            Recruitment(
                companyName: "Gamma Studio",
                badgeText: "Featured",
                titleText: "Product Designer — Motion & Prototyping",
                industryLeft: "Industry",
                industryRight: "Design",
                typeLeft: "Type",
                typeRight: "Contract",
                pay1Label: "Pay1",
                pay1Value: "XX万円",
                pay2Label: "Pay2",
                pay2Value: "XX万円",
                tag1: "#Figma",
                tag2: "#Prototyping",
                tag3: "#Animation",
                deadline: "20XX/3/10 (7Days)",
                classification: "インターン",
                headerImageURL: URL(string: "https://picsum.photos/465/300")!,
                location: "Remote"
            )
        ]
    }
    
    // MARK: - Actions
    
    func handleLike(item: Recruitment) {
        likeCount += 1
        removeCard(item, action: .like)
        // TODO: Hook up analytics or persistence for liked items
    }
    
    func handleDislike(item: Recruitment) {
        skipCount += 1
        removeCard(item, action: .dislike)
        // TODO: Hook up analytics or persistence for disliked items
    }
    
    func undoLastSwipe() {
        guard let removed = lastRemoved else { return }
        
        // Restore the card to the deck
        cards.append(removed)
        
        // Decrement the appropriate counter
        if let action = lastAction {
            switch action {
            case .like:
                likeCount = max(0, likeCount - 1)
            case .dislike:
                skipCount = max(0, skipCount - 1)
            }
        }
        
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
    }
    
    /// Reset the store to initial state
    func reset() {
        cards.removeAll()
        lastRemoved = nil
        lastAction = nil
        likeCount = 0
        skipCount = 0
        loadInitialData()
    }
}
