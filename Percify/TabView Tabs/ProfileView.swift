import SwiftUI
import Shimmer

struct ProfileView: View {
    @Bindable var jobStore: JobStore
    @State private var selectedCard: ProfileCardItem?

    private func settingNavigationLink(icon: String, title: String, gradientColors: [Color]) -> some View {
        NavigationLink {
            ProfileSettingItemPlaceholderView(
                icon: icon,
                title: title,
                gradientColors: gradientColors
            )
        } label: {
            SettingRowView(
                icon: icon,
                title: title,
                gradientColors: gradientColors
            )
        }
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Color(.white))
                                .frame(width: 60, height: 60)
                                .shimmering()
                            Image(systemName: "person.crop.circle")
                                .font(.largeTitle)
                                .foregroundColor(.accentColor)
                                .scaleEffect(2.0)
                        }
                        .clipShape(.circle)
                        VStack(alignment: .leading) {
                            Text("松本 知大")
                                .font(.headline)
                            Text("2028年度卒・慶應義塾大")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .fixedSize(horizontal: true, vertical: false)
                        }
                        Spacer()
                        ArcTextBadgeView()
                    }
                    .listRowBackground(
                        LinearGradient(
                            colors: [Color.accentColor.opacity(0.15), Color(.systemBackground)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    HStack {
                        Text("プロフィールを編集")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                Section {
                    VStack(spacing: 10) {
                        HStack(alignment: .center, spacing: 8) {
                            Button {
                                selectedCard = ProfileCardItem(icon: "heart.circle.fill", title: "お気に入り済み")
                            } label: {
                                VStack(spacing: 10) {
                                    Image(systemName: "heart.circle.fill")
                                        .font(.largeTitle)
                                        .foregroundColor(.accentColor)
                                        .symbolRenderingMode(.hierarchical)
                                    Text("お気に入り済み")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.secondary)
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .padding(.vertical, 12)
                                .background(RoundedRectangle(cornerRadius: 24).fill(Color(.systemBackground)))
                            }
                            .buttonStyle(.plain)
                            Button {
                                selectedCard = ProfileCardItem(icon: "checkmark.circle.fill", title: "エントリー済み")
                            } label: {
                                VStack(spacing: 10) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.largeTitle)
                                        .foregroundColor(.accentColor)
                                        .symbolRenderingMode(.hierarchical)
                                    Text("エントリー済み")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.secondary)
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .padding(.vertical, 12)
                                .background(RoundedRectangle(cornerRadius: 24).fill(Color(.systemBackground)))
                            }
                            .buttonStyle(.plain)
                            Button {
                                selectedCard = ProfileCardItem(icon: "building.2.fill", title: "あなたの企業一覧")
                            } label: {
                                VStack(spacing: 10) {
                                    Image(systemName: "building.2.fill")
                                        .font(.largeTitle)
                                        .foregroundColor(.accentColor)
                                        .symbolRenderingMode(.hierarchical)
                                    Text("あなたの企業一覧")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.secondary)
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .padding(.vertical, 12)
                                .background(RoundedRectangle(cornerRadius: 24).fill(Color(.systemBackground)))
                            }
                            .buttonStyle(.plain)
                        }
                        HStack(alignment: .center, spacing: 8) {
                            Button {
                                selectedCard = ProfileCardItem(icon: "arrowtriangle.up.2.fill", title: "スキップ済み")
                            } label: {
                                VStack(spacing: 10) {
                                    Image(systemName: "arrowtriangle.up.2.fill")
                                        .font(.largeTitle)
                                        .foregroundColor(.accentColor)
                                        .symbolRenderingMode(.hierarchical)
                                        .rotationEffect(.degrees(90))
                                    Text("スキップ済み")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.secondary)
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .padding(.vertical, 12)
                                .background(RoundedRectangle(cornerRadius: 24).fill(Color(.systemBackground)))
                            }
                            .buttonStyle(.plain)
                            .opacity(1.0)
                            VStack(spacing: 10) {
                                Image(systemName: "list.bullet.clipboard.fill")
                                    .font(.largeTitle)
                                    .foregroundColor(.accentColor)
                                    .symbolRenderingMode(.hierarchical)
                                Text("選考状況")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding(.vertical, 12)
                            .background(RoundedRectangle(cornerRadius: 24).fill(Color(.systemBackground)))
                            .opacity(0.0)
                            VStack(spacing: 10) {
                                Image(systemName: "list.bullet.clipboard.fill")
                                    .font(.largeTitle)
                                    .foregroundColor(.accentColor)
                                    .symbolRenderingMode(.hierarchical)
                                Text("選考状況")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding(.vertical, 12)
                            .background(RoundedRectangle(cornerRadius: 24).fill(Color(.systemBackground)))
                            .opacity(0.0)
                        }
                    }
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, -16)
                    .listRowBackground(Color.clear)
                }
                Section {
                    ZStack {
                        HStack {
                            Spacer()
                            ZStack {
                                Image(systemName: "person.text.rectangle")
                                Image(systemName: "sparkles.2")
                                    .offset(x: 50)
                                    .scaleEffect(0.8)
                                    .offset(y: -10)
                            }
                                .font(.largeTitle)
                                .foregroundColor(.white.opacity(0.15))
                                .scaleEffect(4.2)
                                .offset(y: 30)
                            Spacer()
                            Spacer()
                            Spacer()
                        }
                        HStack(spacing: 16) {
                            Text("プロフィールを充実させて、スカウトを受けとろう!")
                                .font(.headline)
                                .foregroundColor(.white)
                            Spacer()
                            Text("編集")
                                .font(.headline)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .foregroundColor(.white)
                                .glassEffect(.clear.interactive())
                        }
                        .padding(.vertical)
                        .padding(.horizontal)
                    }
                    .listRowBackground(LinearGradient(colors: [.accentColor.opacity(0.65), .accentColor], startPoint: .top, endPoint: .bottom))
                }
                Section {
                    settingNavigationLink(
                        icon: "bell.badge.fill",
                        title: "通知設定",
                        gradientColors: [.pink.opacity(0.5), .pink]
                    )
                    settingNavigationLink(
                        icon: "arrow.right.circle",
                        title: "内定者アカウントに移行",
                        gradientColors: [.blue.opacity(0.5), .blue]
                    )
                    settingNavigationLink(
                        icon: "text.page.fill",
                        title: "利用規約",
                        gradientColors: [.gray.opacity(0.5), .gray]
                    )
                    settingNavigationLink(
                        icon: "hand.raised.fill",
                        title: "プライバシーポリシー",
                        gradientColors: [.blue.opacity(0.5), .blue]
                    )
                    settingNavigationLink(
                        icon: "richtext.page.fill",
                        title: "コンテンツポリシー",
                        gradientColors: [.gray.opacity(0.5), .gray]
                    )
                    settingNavigationLink(
                        icon: "building.2.fill",
                        title: "運営会社",
                        gradientColors: [.gray.opacity(0.5), .gray]
                    )
                    settingNavigationLink(
                        icon: "checkmark.seal.text.page.fill",
                        title: "オープンソースライセンス",
                        gradientColors: [.gray.opacity(0.5), .gray]
                    )
                }
                Section {
                    settingNavigationLink(
                        icon: "list.bullet",
                        title: "よくあるご質問",
                        gradientColors: [.gray.opacity(0.5), .gray]
                    )
                    settingNavigationLink(
                        icon: "questionmark.bubble.fill",
                        title: "お問い合わせ",
                        gradientColors: [.purple.opacity(0.5), .purple]
                    )
                }
                Section {
                    HStack {
                        Spacer()
                        Text("サインアウト")
                            .foregroundColor(.red)
                        Spacer()
                    }
                    HStack {
                        Spacer()
                        Text("退会")
                            .foregroundColor(.red)
                        Spacer()
                    }
                }
            }
            .listStyle(.insetGrouped)
            .listSectionSpacing(.compact)
            .padding(.top, -20)
            .navigationDestination(item: $selectedCard) { card in
                if card.title == "あなたの企業一覧" {
                    FavoriteCompaniesView(jobStore: jobStore)
                } else if card.title == "エントリー済み" {
                    EnteredJobsListView(jobStore: jobStore)
                } else {
                    ProfileSettingItemPlaceholderView(
                        icon: card.icon,
                        title: card.title,
                        gradientColors: [.accentColor.opacity(0.5), .accentColor]
                    )
                }
            }
            .navigationTitle("マイページ")
            .toolbarTitleDisplayMode(.inlineLarge)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("サインアウト") {
                        // TODO: Handle logout
                    }
                    .tint(.red)
                }
            }
        }
    }
}

struct ProfileCardItem: Hashable, Identifiable {
    let icon: String
    let title: String
    var id: String { title }
}

struct ArcTextBadgeView: View {
    let topText = "PERCIFY就活"
    let bottomText = "2026年9月登録"
    let size: CGFloat = 60
    let radius: CGFloat = 24

    var body: some View {
        ZStack {
            // Top arc text
            ArcText(text: topText, radius: radius, startAngle: -150, endAngle: -30, flipped: false)
            // Bottom arc text
            ArcText(text: bottomText, radius: radius, startAngle: 30, endAngle: 150, flipped: true)
            // Separator dots
            Circle()
                .frame(width: 3.5, height: 3.5)
                .offset(x: radius, y: 0)
            Circle()
                .frame(width: 3.5, height: 3.5)
                .offset(x: -radius, y: 0)
            // Center logo
            Image("Percify")
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .foregroundStyle(Color.accentColor)
                .frame(width: size * 0.45, height: size * 0.45)
        }
        .frame(width: size, height: size)
        .font(.system(size: 6.5, weight: .bold))
        .foregroundColor(.accentColor)
    }
}

struct ArcText: View {
    let text: String
    let radius: CGFloat
    let startAngle: Double
    let endAngle: Double
    let flipped: Bool

    var body: some View {
        let chars = Array(text)
        let totalAngle = endAngle - startAngle
        let step = totalAngle / Double(max(chars.count - 1, 1))

        ZStack {
            ForEach(0..<chars.count, id: \.self) { i in
                let angle = flipped ? endAngle - Double(i) * step : startAngle + Double(i) * step
                let rad = angle * .pi / 180
                let x = CGFloat(cos(rad)) * radius
                let y = CGFloat(sin(rad)) * radius
                let rotation = flipped ? angle - 90 : angle + 90

                Text(String(chars[i]))
                    .rotationEffect(.degrees(rotation))
                    .offset(x: x, y: y)
            }
        }
    }
}

struct SettingRowView: View {
    let icon: String
    let title: String
    let gradientColors: [Color]

    var body: some View {
        HStack {
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color.white)
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: gradientColors),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                Image(systemName: icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 17, height: 17)
                    .foregroundColor(.white)
                    .fontWeight(.semibold)
            }
            .frame(width: 28, height: 28)
            Text(title)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.subheadline)
                .foregroundColor(.clear.opacity(0.6))
        }
    }
}

// MARK: - Entered Jobs List

struct EnteredJobsListView: View {
    var jobStore: JobStore

    var body: some View {
        List {
            if jobStore.enteredJobs.isEmpty {
                ContentUnavailableView(
                    "エントリーはまだありません",
                    systemImage: "checkmark.circle",
                    description: Text("求人やイベントにエントリーすると、ここに表示されます。")
                )
            } else {
                ForEach(jobStore.enteredJobs) { entry in
                    HStack(spacing: 14) {
                        Image(entry.companyLogo)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 44, height: 44)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .strokeBorder(Color(.separator), lineWidth: 0.5)
                            )
                        VStack(alignment: .leading, spacing: 4) {
                            Text(entry.companyName)
                                .font(.headline)
                            Text(entry.title)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .lineLimit(2)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text(entry.enteredDate, style: .date)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle("エントリー済み")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    ProfileView(jobStore: JobStore())
}


