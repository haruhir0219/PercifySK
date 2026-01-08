import SwiftUI

struct MessagesView: View {
    @Namespace var transition
    @State private var isShowingSearch = false
    @State private var isShowingMembership = false
    @State private var isShowingArchived = false
    @State private var chatStore = ChatStore()
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(chatStore.activeChats) { chat in
                    NavigationLink {
                        MessageDetailsView(chat: chat) {
                            // Decline callback
                            chatStore.declineChat(chat)
                        }
                        .toolbar(.hidden, for: .tabBar)
                    } label: {
                        VStack(spacing: 0) {
                            ChatRowView(chat: chat, isPriorityVariant: chat.isPriority)
                                .padding(.horizontal)
                                .padding(.vertical, 8)
                            
                            if chat.id != chatStore.activeChats.last?.id {
                                Divider()
                                    .padding(.leading, 88)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.top, 8)
        }
        .background(
            LinearGradient(
                colors: [
                    Color.indigo.opacity(0.7), Color.purple.opacity(0.15), Color(.systemGroupedBackground), Color(.systemGroupedBackground), Color(.systemGroupedBackground), Color(.systemGroupedBackground), Color(.systemGroupedBackground)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .padding(.all, -50)
            .ignoresSafeArea()
        )
        .navigationTitle("メッセージ")
        .toolbarTitleDisplayMode(.inlineLarge)
        .toolbar {
            ToolbarSpacer(.fixed)
            ToolbarSpacer(.fixed, placement: .topBarTrailing)
            ToolbarItemGroup(placement: .topBarTrailing) {
                HStack {
                    Button(action: { isShowingMembership = true }) {
                        Image(systemName: "star")
                    }
                }
                .matchedTransitionSource(id: "membership", in: transition)
                HStack {
                    Button(action: { isShowingSearch = true }) {
                        Image(systemName: "line.3.horizontal.decrease")
                    }
                }
                .matchedTransitionSource(id: "search", in: transition)
                HStack {
                    Button(action: { isShowingSearch = true }) {
                        Image(systemName: "magnifyingglass")
                    }
                }
                .matchedTransitionSource(id: "search", in: transition)
            }
        }
        .sheet(isPresented: $isShowingSearch) {
            MessagesArchivedView(chatStore: chatStore)
                .navigationTransition(.zoom(sourceID: "search", in: transition))
        }
        .sheet(isPresented: $isShowingMembership) {
            MembershipView()
                .navigationTransition(.zoom(sourceID: "membership", in: transition))
        }
    }
}

#Preview {
    NavigationStack {
        MessagesView()
    }
}

// MARK: - Chat Row View

struct ChatRowView: View {
    let chat: Chat
    let isPriorityVariant: Bool
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            // Chat content
            HStack(alignment: .top, spacing: 26) {
                // Spacer for logo
                Color.clear
                    .frame(width: 60, height: 60)
                
                VStack(alignment: .leading, spacing: 4) {
                    // Top row: Badge and company name
                    HStack(alignment: .center, spacing: 8) {
                        if isPriorityVariant {
                            // Priority badge pill
                            //Text("Percify特別選考ルート")
                            //.font(.headline)
                            //.foregroundColor(.white)
                            //.padding(.horizontal, 10)
                            //.padding(.vertical, 4)
                            //.background(
                            //Capsule()
                            //.fill(
                            //LinearGradient(
                            //colors: [.accentColor.opacity(0.9), .indigo.opacity(0.8)],
                            //startPoint: .top,
                            //endPoint: .bottom
                            //)
                            //)
                            //)
                        }
                        
                        Spacer()
                    }
                    
                    // Company name
                    HStack(alignment: .center, spacing: 8) {
                        Text(chat.companyName)
                            .font(.headline)
                            .foregroundColor(.primary)
                            .lineLimit(1)
                            .offset(y: isPriorityVariant ? 12 : 0)
                        
                        Spacer()
                        
                        // Timestamp
                        HStack {
                            Text("2件未読")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .lineLimit(1)
                                .padding(.vertical, 1)
                                .padding(.horizontal, 6)
                                .background(Color(Color.red).cornerRadius(12))
                            Text(chat.timestamp)
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Message preview with chevron
                    HStack(alignment: .center, spacing: 4) {
                        Text(chat.messagePreview)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                            .offset(y: isPriorityVariant ? 12 : 0)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.vertical, 14)
            .contentShape(Rectangle())
            
            // Company Logo with optional priority outline (overlaid on top)
            ZStack {
                Circle()
                    .fill(Color(.systemBackground))
                
                Image(chat.companyLogo)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
            }
            .frame(width: 60, height: 60)
            .padding(isPriorityVariant ? 3 : 3)
            .background(
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [.accentColor.opacity(0.9), .indigo.opacity(0.8)],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: isPriorityVariant ? 8 : 0
                    )
            )
            .overlay(
                HStack {
                    Text("Percify特別選考")
                        .font(.system(size: 9.5, weight: .heavy))
                }
                    .fontWeight(.heavy)
                    .foregroundColor(.accentColor)
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .glassEffect(.regular)
                    .offset(x: 110, y: -27)
                    .opacity(isPriorityVariant ? 1 : 0)
        )
            .overlay(
                VStack {
                    AsyncImage(url: URL(string: "https://media.istockphoto.com/id/1138617116/photo/im-happy-with-where-my-career-is-heading.jpg?s=612x612&w=0&k=20&c=33MvgqW7x0F3u86R-OculcAccnIxzBOIvXZ4nyjOSgM=")) { phase in
                        switch phase {
                        case .empty:
                            Circle()
                                .fill(Color(.systemGray5))
                                .shimmering()
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                        case .failure:
                            Circle()
                                .fill(Color(.systemGray5))
                                .overlay(
                                    Image(systemName: "exclamationmark.circle")
                                        .foregroundColor(.gray)
                                )
                        @unknown default:
                            Circle()
                                .fill(Color(.white))
                        }
                    }
                    .frame(width: 32, height: 32)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                }
                    .offset(x: 22, y: 25)
        )
            .offset(y: 8)
        }
    }
}

// MARK: - Circular Text Helper

struct CircularTextShape: Shape {
    let text: String
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let radius = min(rect.width, rect.height) / 2
        let center = CGPoint(x: rect.midX, y: rect.midY)
        
        // Create a circular path
        path.addArc(center: center, radius: radius, startAngle: .degrees(0), endAngle: .degrees(90), clockwise: true)
        
        return path
    }
}

struct CircularTextView: View {
    let text: String
    
    var body: some View {
        Canvas { context, size in
            let radius = min(size.width, size.height) / 2
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let characterCount = CGFloat(text.count)
            let totalAngle: CGFloat = 360 // Full circle
            let anglePerCharacter = totalAngle / characterCount
            
            for (index, character) in text.enumerated() {
                let angle = anglePerCharacter * CGFloat(index) - 90 // Start from top
                let radians = angle * .pi / 180
                
                let x = center.x + radius * cos(radians)
                let y = center.y + radius * sin(radians)
                
                var textContext = context
                textContext.translateBy(x: x, y: y)
                textContext.rotate(by: .degrees(angle + 90))
                
                textContext.draw(
                    Text(String(character))
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(.white),
                    at: .zero
                )
            }
        }
    }
}
