import SwiftUI

struct HomeView: View {
    @Namespace var transition
    @State private var isShowingSearch = false
    @State private var isShowingMembership = false
    @State private var isShowingEventDetail = false
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.indigo.opacity(0.7), Color.purple.opacity(0.15), Color(.systemGroupedBackground), Color(.systemGroupedBackground), Color(.systemGroupedBackground), Color(.systemGroupedBackground), Color(.systemGroupedBackground)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .padding(.all, -50)
            .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Featured Card
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(0..<3) { _ in
                                ZStack(alignment: .topLeading) {
                                    Image("expo2")
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 340, height: 220)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                    
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text(" ")
                                            .font(.headline)
                                            .foregroundColor(.black)
                                        
                                        Text("就活EXPO\n2025")
                                            .font(.system(size: 48, weight: .bold, design: .rounded))
                                            .foregroundColor(.clear)
                                    }
                                    .padding()
                                }
                                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                                .onTapGesture {
                                    isShowingEventDetail = true
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical)
                    }
                    
                    // Horizontal Scrolling Section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("慶應義塾大学で人気の選考")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 18) {
                                ForEach(0..<5) { index in
                                    VStack(alignment: .leading, spacing: 6) {
                                        ZStack(alignment: .topLeading) {
                                            AsyncImage(url: URL(string: cardImageURL(for: index))) { phase in
                                                switch phase {
                                                case .empty:
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .fill(cardColor(for: index))
                                                        .shimmering()
                                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                                        .frame(width: 240, height: 180)
                                                case .success(let image):
                                                    image
                                                        .resizable()
                                                        .scaledToFill()
                                                        .frame(width: 240, height: 180)
                                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                                case .failure:
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .fill(cardColor(for: index))
                                                        .frame(width: 240, height: 180)
                                                        .overlay(
                                                            Image(systemName: "photo")
                                                                .foregroundColor(.white)
                                                        )
                                                @unknown default:
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .fill(cardColor(for: index))
                                                        .frame(width: 240, height: 180)
                                                }
                                            }
                                            
                                            VStack(alignment: .center) {
                                                Image("Itochu")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(height: 100)
                                                    .clipShape(Circle())
                                            }
                                            .padding(10)
                                            .frame(width: 240, height: 180, alignment: .center)
                                        }
                                        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                                        HStack {
                                            VStack(alignment: .leading) {
                                                Text(cardSubtitle(for: index))
                                                    .font(.caption2)
                                                    .foregroundColor(.secondary)
                                                Text(cardTitle(for: index))
                                                    .font(.headline)
                                                    .fontWeight(.medium)
                                                    .lineLimit(1)
                                            }
                                            Spacer()
                                            VStack(alignment: .trailing) {
                                                Text("本選考")
                                                    .font(.caption2)
                                                    .foregroundColor(.secondary)
                                                    .padding(.horizontal, 6)
                                                    .padding(.vertical, 2)
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 6)
                                                            .stroke(Color.secondary.opacity(0.5), lineWidth: 1)
                                                    )
                                                Text("締切まで50日")
                                                    .font(.caption2)
                                                    .fontWeight(.medium)
                                                    .lineLimit(1)
                                            }
                                        }
                                    }
                                    .frame(width: 240)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    //duplictae
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("締切間近の選考")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 18) {
                                ForEach(0..<5) { index in
                                    VStack(alignment: .leading, spacing: 6) {
                                        ZStack(alignment: .topLeading) {
                                            AsyncImage(url: URL(string: cardImageURL(for: index))) { phase in
                                                switch phase {
                                                case .empty:
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .fill(cardColor(for: index))
                                                        .frame(width: 240, height: 180)
                                                case .success(let image):
                                                    image
                                                        .resizable()
                                                        .scaledToFill()
                                                        .frame(width: 240, height: 180)
                                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                                        .overlay(
                                                            RoundedRectangle(cornerRadius: 15)
                                                                .strokeBorder(Color.accentColor.opacity(0.6), lineWidth: 6)
                                                        )
                                                        .overlay(
                                                            ZStack {
                                                                Capsule()
                                                                    .frame(width: 85, height: 30)
                                                                    .glassEffect(.regular.tint(.accentColor))
                                                                HStack {
                                                                    Image.init(systemName: "circle", variableValue: 0.3)
                                                                        .symbolVariableValueMode(.draw)
                                                                        .font(.title2)
                                                                        .fontWeight(.semibold)
                                                                        .foregroundStyle(Color.white)
                                                                        .overlay(Text("L") .font(.caption)
                                                                            .fontWeight(.bold).foregroundStyle(Color.white).fontDesign(.rounded).padding(.bottom, 3).padding(.leading, 2))
                                                                    Text("あと2日")
                                                                        .font(.caption)
                                                                        .fontWeight(.semibold)
                                                                        .foregroundColor(.white)
                                                                }
                                                            }
                                                                .offset(x: 70, y: -65)
                                                        )
                                                case .failure:
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .fill(cardColor(for: index))
                                                        .frame(width: 240, height: 180)
                                                        .overlay(
                                                            Image(systemName: "photo")
                                                                .foregroundColor(.white)
                                                        )
                                                @unknown default:
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .fill(cardColor(for: index))
                                                        .frame(width: 240, height: 180)
                                                }
                                            }
                                            
                                            VStack(alignment: .center) {
                                                Image("Itochu")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(height: 100)
                                                    .clipShape(Circle())
                                            }
                                            .padding(10)
                                            .frame(width: 240, height: 180, alignment: .center)
                                        }
                                        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                                        HStack {
                                            VStack(alignment: .leading) {
                                                Text(cardSubtitle(for: index))
                                                    .font(.caption2)
                                                    .foregroundColor(.secondary)
                                                Text(cardTitle(for: index))
                                                    .font(.headline)
                                                    .fontWeight(.medium)
                                                    .lineLimit(1)
                                            }
                                            Spacer()
                                            VStack(alignment: .trailing) {
                                                Text("本選考")
                                                    .font(.caption2)
                                                    .foregroundColor(.secondary)
                                                    .padding(.horizontal, 6)
                                                    .padding(.vertical, 2)
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 6)
                                                            .stroke(Color.secondary.opacity(0.5), lineWidth: 1)
                                                    )
                                                Text("締切まで50日")
                                                    .font(.caption2)
                                                    .fontWeight(.medium)
                                                    .lineLimit(1)
                                            }
                                        }
                                    }
                                    .frame(width: 240)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical)
            }
        }
        .navigationTitle("ホーム")
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
            SearchView()
                .navigationTransition(.zoom(sourceID: "search", in: transition))
        }
        .sheet(isPresented: $isShowingMembership) {
            MembershipView()
                .navigationTransition(.zoom(sourceID: "membership", in: transition))
        }
        .sheet(isPresented: $isShowingEventDetail) {
            if let url = URL(string: "https://percify.jp/student/service/event/expo/27/250517?trk=public_post_reshare-text") {
                WebViewSheet(url: url)
            }
        }
    }
    
    // Helper functions for card content
    private func cardColor(for index: Int) -> LinearGradient {
        let colors: [[Color]] = [
            [.gray, .gray],
            [.gray, .gray],
            [.gray, .gray],
            [.gray, .gray],
            [.gray, .gray]
        ]
        return LinearGradient(
            colors: colors[index % colors.count],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private func cardTitle(for index: Int) -> String {
        let titles = [
            "伊藤忠商事",
            "オリエンタルランド",
            "バイバイト"
        ]
        return titles[index % titles.count]
    }
    
    private func cardSubtitle(for index: Int) -> String {
        let subtitles = [
            "総合商社",
            "ホスピタリティ",
            "スタートアップ" ]
        return subtitles[index % subtitles.count]
    }
    
    private func cardImageURL(for index: Int) -> String {
        let imageURLs = [
            "https://sun-ad.co.jp/wp-content/uploads/2018/04/itochu_mv_1_2.jpg",
            "https://world-of-disney.com/wp-content/uploads/2025/07/IMG_202306_063Pcrs.jpg",
            "https://example.com/image3.jpg"
        ]
        return imageURLs[index % imageURLs.count]
    }
}

#Preview {
    NavigationStack {
        HomeView()
    }
}

