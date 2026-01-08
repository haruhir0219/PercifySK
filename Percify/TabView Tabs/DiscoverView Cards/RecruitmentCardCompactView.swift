//
//  RecruitmentCardCompactView.swift
//  Percify
//
//  Created by 松本知大 on 2025/12/16.
//

import SwiftUI
import Glur

struct RecruitmentCardCompactView: View {
    let recruitment: Recruitment
    @State private var showDetails: Bool = false
    @Binding var isSelected: Bool
    @Namespace var transition
    
    init(recruitment: Recruitment, isSelected: Binding<Bool> = .constant(false)) {
        self.recruitment = recruitment
        self._isSelected = isSelected
    }
    
    var body: some View {
        Button {
            showDetails = true
        } label: {
            cardContent
        }
        .buttonStyle(CompactCardButtonStyle())
        .frame(height: UIScreen.main.bounds.height * 0.31) // Half the original height
        .fullScreenCover(isPresented: $showDetails) {
            RecruitmentDetailsView(
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
            .navigationTransition(.zoom(sourceID: "compactCard\(recruitment.id)", in: transition))
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("Job card for \(recruitment.titleText) at \(recruitment.companyName)"))
        .accessibilityAddTraits(.isButton)
    }
    
    // MARK: - Card Content
    
    private var cardContent: some View {
        ZStack(alignment: .topLeading) {
            cardBackground
            
            VStack(alignment: .leading, spacing: 0) {
                // Top badge
                HStack {
                    Spacer()
                    badgePill
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                
                Spacer()
                
                // Bottom content
                VStack(alignment: .leading, spacing: 12) {
                    VStack(alignment: .center, spacing: 12) {
                        HStack {
                            Image(recruitment.companyLogo)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 44, height: 44)
                                .clipShape(Circle())
                            Spacer()
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(recruitment.companyName)
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                            
                            Text(recruitment.titleText)
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundStyle(.primary)
                                .lineLimit(2)
                        }
                    }
                }
                //.padding(16)
                .padding(12)
                .padding(.bottom, 10)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(alignment: .topLeading) {
            checkboxOverlay
        }
        .matchedTransitionSource(id: "compactCard\(recruitment.id)", in: transition)
    }
    
    // MARK: - Card Background
    
    private var cardBackground: some View {
        AsyncImage(url: recruitment.headerImageURL) { phase in
            switch phase {
            case .empty:
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color(.systemGray5))
                    .frame(width: UIScreen.main.bounds.width * 0.438)
                    .frame(height: UIScreen.main.bounds.height * 0.31)
                    .shimmering()
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .frame(width: UIScreen.main.bounds.width * 0.438)
                    .frame(height: UIScreen.main.bounds.height * 0.31)
                    .clipped()
                    .overlay(
                        LinearGradient(
                            gradient: Gradient(colors: [.clear, .white.opacity(0.5)]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .overlay(
                        LinearGradient(
                            gradient: Gradient(colors: [.clear, .clear, .white.opacity(0.3), .white.opacity(0.6)]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .glur(radius: 20.0,
                          offset: 0.45,
                          interpolation: 0.2,
                          direction: .down,
                          noise: 0.0,
                          drawingGroup: false
                    )
                    .glur(radius: 12.0,
                          offset: 0.03,
                          interpolation: 0.2,
                          direction: .up,
                          noise: 0.0,
                          drawingGroup: false
                    )
            case .failure:
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color.gray.opacity(0.25))
            @unknown default:
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color.gray.opacity(0.15))
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(Color.white.opacity(0.15), lineWidth: 1)
        )
    }
    
    // MARK: - Badge
    
    private var badgePill: some View {
        Text(recruitment.badgeText)
            .font(.caption)
            .fontWeight(.semibold)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                LinearGradient(colors: [.purple, .purple], startPoint: .top, endPoint: .bottom)
                    .overlay(
                        LinearGradient(colors: [.clear, .white.opacity(0.2)], startPoint: .bottom, endPoint: .top)
                    )
                    .clipShape(Capsule())
                    .overlay(
                        Capsule()
                            .strokeBorder(Color.white.opacity(0.4), lineWidth: 1)
                    )
            )
            .foregroundStyle(.white)
    }
    
    // MARK: - Checkbox Overlay
    
    private var checkboxOverlay: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isSelected.toggle()
            }
        } label: {
            ZStack {
                Circle()
                    .fill(.white.opacity(0.3))
                    .frame(width: 26, height: 26)
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title)
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(isSelected ? .purple : .white.opacity(0.5), .white)
                    .fontWeight(isSelected ? .regular : .thin)
            }
        }
        .padding(12)
    }
}

// MARK: - Button Style

struct CompactCardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Preview

#Preview {
    ScrollView {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12)
        ], spacing: 16) {
            ForEach(0..<6) { index in
                RecruitmentCardCompactView(
                    recruitment: Recruitment(
                        companyName: "SMBCアビエーション",
                        companyLogo: "Itochu",
                        badgeText: "人気",
                        titleText: "SMBCアビエーションキャピタル事業本部",
                        industryLeft: "Industry",
                        industryRight: "金融",
                        typeLeft: "Type",
                        typeRight: "総合職",
                        pay1Label: "Pay1",
                        pay1Value: "450万円",
                        pay2Label: "Pay2",
                        pay2Value: "650万円",
                        tag1: "#Tag Text 1",
                        tag2: "#Tag Text 2",
                        tag3: "#Tag Text 3",
                        deadline: "20XX/X/X",
                        classification: "Classification",
                        headerImageURL: URL(string: "https://arquitecturaviva.com/assets/uploads/obras/53847/av_218477.webp?h=c3137801")!,
                        location: "Tokyo"
                    )
                )
            }
        }
        .padding()
    }
    .background(
        LinearGradient(colors: [.indigo.opacity(0.6), .purple.opacity(0.2)], startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()
    )
}
