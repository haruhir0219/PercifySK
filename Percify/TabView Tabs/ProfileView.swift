import SwiftUI
import Shimmer

struct ProfileView: View {
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
                            Text("2028年度卒")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
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
                        HStack(alignment: .center, spacing: 8) {
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
                    SettingRowView(
                        icon: "bell.badge.fill",
                        title: "通知設定",
                        gradientColors: [.pink.opacity(0.5), .pink]
                    )
                    SettingRowView(
                        icon: "lock.shield.fill",
                        title: "qufqwfebec",
                        gradientColors: [.green.opacity(0.5), .green]
                    )
                    SettingRowView(
                        icon: "gearshape.fill",
                        title: "ggta",
                        gradientColors: [.gray.opacity(0.5), .gray]
                    )
                }
            }
            .listStyle(.insetGrouped)
            .listSectionSpacing(.compact)
            .padding(.top, -20)
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
                .foregroundColor(.secondary.opacity(0.6))
        }
    }
}

#Preview {
    ProfileView()
}


