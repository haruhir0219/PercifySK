import SwiftUI

struct ProfileView: View {
    var body: some View {
        NavigationStack {
            List {
                Section {
                    SettingRowView(
                        icon: "person.crop.circle",
                        title: "Qfdbfou",
                        gradientColors: [.blue.opacity(0.5), .blue]
                    )
                    SettingRowView(
                        icon: "mappin.and.ellipse",
                        title: "quebec",
                        gradientColors: [.orange.opacity(0.5), .orange]
                    )
                    SettingRowView(
                        icon: "star.fill",
                        title: "gdyuaf",
                        gradientColors: [.yellow.opacity(0.5), .yellow]
                    )
                }
                Section {
                    SettingRowView(
                        icon: "bell.badge.fill",
                        title: "ewf",
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
            .navigationTitle("プロフィール")
            .toolbarTitleDisplayMode(.inlineLarge)
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
        }
    }
}

#Preview {
    ProfileView()
}
