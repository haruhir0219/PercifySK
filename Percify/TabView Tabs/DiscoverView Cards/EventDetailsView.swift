//

import SwiftUI
import UIKit
import Charts

// MARK: - Simple helpers / stubs (replace with your real ones later if needed)

private var isMaxOrPlusIPhone: Bool {
#if os(iOS)
    if UIDevice.current.userInterfaceIdiom == .phone {
        let screenMax = max(UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.height)
        return screenMax >= 896 // iPhone Plus/Max sizes (height in points)
    }
#endif
    return false
}

/// Lightweight "glass" container using system materials (no dependencies)
struct GlassEffectContainer2<Content: View>: View {
    let content: Content
    init(@ViewBuilder content: () -> Content) { self.content = content() }
    var body: some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .fill(.white)
            )
            .drawingGroup()
    }
}

/// No-op but keeps call-sites intact
extension View {
    func glassEffect2(_ style: Any? = nil, in shape: Any? = nil) -> some View { self }
}

/// Simple shimmering stand-in (remove if unwanted)
extension View {
    func shimmeringPlaceholder2(_ active: Bool = true) -> some View {
        self
            .redacted(reason: active ? .placeholder : [])
            .opacity(active ? 0.9 : 1.0)
    }
}

// MARK: - Job section kind (since original referenced an external type)

enum JobSectionKind2: CaseIterable, Hashable {
    case top, qualification, description, salary, period, shift, weekdays, benefits, access, flowAfterApply

    var title: String {
        switch self {
        case .top:  return "企業トップ"
        case .qualification:  return "応募資格"
        case .description:    return "仕事内容"
        case .salary:         return "給与"
        case .period:         return "期間"
        case .shift:          return "シフト・時間"
        case .weekdays:       return "勤務日"
        case .benefits:       return "待遇・福利厚生"
        case .access:         return "アクセス"
        case .flowAfterApply: return "応募後の流れ"
        }
    }
    var icon: String {
        switch self {
        case .top:    return "star.fill"
        case .qualification:  return "star"
        case .description:    return "text.book.closed.fill"
        case .salary:         return "yensign.circle.fill"
        case .period:         return "calendar"
        case .shift:          return "clock.fill"
        case .weekdays:       return "calendar.day.timeline.left"
        case .benefits:       return "gift.fill"
        case .access:         return "mappin.and.ellipse"
        case .flowAfterApply: return "arrow.triangle.2.circlepath"
        }
    }
    var iconColor: Color {
        switch self {
        case .top:  return .blue
        case .qualification:  return .green
        case .description:    return .blue
        case .salary:         return .orange
        case .period:         return .purple
        case .shift:          return .teal
        case .weekdays:       return .indigo
        case .benefits:       return .pink
        case .access:         return .red
        case .flowAfterApply: return .cyan
        }
    }
}

// MARK: - Grid Cell Model

struct SelectionStep {
    let mainText: String
    let subText: String?
    
    init(mainText: String, subText: String? = nil) {
        self.mainText = mainText
        self.subText = subText
    }
}

// MARK: - Tags Flow Layout (extracted for performance)

struct TagsFlowLayout: View, Equatable {
    private let tags = ["フレックスタイム制あり", "ワーク・ライフバランス重視", "副業OK", "新規事業立ち上げ・事業開発"]
    
    static func == (lhs: TagsFlowLayout, rhs: TagsFlowLayout) -> Bool {
        true // Static tags, always equal
    }
    
    var body: some View {
        FlowLayout(tags: tags) { tag in
            Text("#" + tag.trimmingCharacters(in: .whitespaces))
                .font(.caption)
                .fontWeight(.semibold)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.accentColor.opacity(0.15))
                .clipShape(Capsule())
                .foregroundColor(.accentColor)
        }
    }
}

// MARK: - Info Row (extracted for performance)

struct InfoRowView: View {
    let icon: String
    let label: String
    let value: String
    let iconLeadingPadding: CGFloat
    let labelLeadingPadding: CGFloat
    
    init(icon: String, label: String, value: String, iconLeadingPadding: CGFloat = 0, labelLeadingPadding: CGFloat = 0) {
        self.icon = icon
        self.label = label
        self.value = value
        self.iconLeadingPadding = iconLeadingPadding
        self.labelLeadingPadding = labelLeadingPadding
    }
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon).foregroundStyle(Color.secondary)
                .font(.caption)
                .padding(.leading, iconLeadingPadding)
            Text(label).foregroundStyle(.secondary).fontWeight(.semibold).font(.caption)
                .padding(.leading, labelLeadingPadding)
            Text(value).foregroundStyle(.secondary).font(.caption)
        }
        .padding(.horizontal)
    }
}

// MARK: - Salary Chart View (extracted for performance)

struct SalaryChartView: View, Equatable {
    let chartData: [Double]
    let animateChart: Bool
    
    static func == (lhs: SalaryChartView, rhs: SalaryChartView) -> Bool {
        lhs.animateChart == rhs.animateChart && lhs.chartData.count == rhs.chartData.count
    }
    
    var body: some View {
        Chart {
            ForEach(Array(chartData.enumerated()), id: \.offset) { index, value in
                LineMark(
                    x: .value("Index", index),
                    y: .value("Value", animateChart ? value : 0)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.accentColor.opacity(0.4), Color.accentColor.opacity(0.1)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .interpolationMethod(.catmullRom)
                .lineStyle(StrokeStyle(lineWidth: 2.5))
                
                AreaMark(
                    x: .value("Index", index),
                    y: .value("Value", animateChart ? value : 0)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.accentColor.opacity(0.15), Color.accentColor.opacity(0.00)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .interpolationMethod(.catmullRom)
            }
        }
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
        .chartYScale(domain: 0...100)
        .frame(height: 100)
        .padding(.horizontal, -10)
        .mask(
            LinearGradient(
                colors: [.clear, .black, .black, .black, .clear],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .allowsHitTesting(false)
    }
}

// MARK: - Event Info List Sections (extracted for performance)

struct EventOverviewSection: View, Equatable {
    static func == (lhs: EventOverviewSection, rhs: EventOverviewSection) -> Bool {
        true // Static content
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "document")
                    .foregroundColor(.secondary)
                Text("概要")
                    .font(.title2)
                    .fontWeight(.semibold)
            }
            Text("""
                金融×ITの上場コンサル「Solvvy(ソルヴィー)」で、自分発のキャリアを描いてみませんか？
                
                Solvvyが今、本気で出会いたいのは——
                若いうちから裁量を持ち、チャレンジできる環境に身を置きたい。
                安定だけではなく、自ら成長のきっかけを掴みにいきたい。
                将来は経営や起業にも挑戦してみたい。
                ——そんな熱を持った学生の方です。
                
                「でも、まだやりたいことが明確に決まっているわけじゃない…」
                「自分にコンサルが合っているのかもわからない…」
                もちろん、それで大丈夫です。
                
                Solvvyでは、入社前から完璧である必要はありません。
                私たちが重視しているのは、"これから"の可能性です。
                堅苦しい準備も不要。こちらからの一方的な時間ではなく、
                あなたが気になることに丁寧に向き合う「対話の時間」にしたいと考えています。
                
                少しでもSolvvyに興味を持っていただけたら、お気軽にエントリーをしてください。
                あなたの「これから」にとって、少しでもヒントになる時間になればうれしいです！
                お会いできるのを楽しみにしています！
                """)
            .font(.subheadline)
            .foregroundColor(.primary)
        }
        .padding()
        .padding(.vertical, 4)
    }
}

struct SelectionFlowSection: View {
    let generalSteps: [SelectionStep]
    let percifySteps: [SelectionStep]
    @Binding var showApplySheet: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 36) {
            VStack(alignment: .leading, spacing: 12) {
                Text("ライバルよりも\n一歩先に、夢の企業へ。\nPercify特別選考なら。")
                    .font(.title)
                    .foregroundColor(.white)
                    .fontWeight(.bold)
                Text("完全審査制だからこそできる、Percify就活アプリからのみの限定。")
                    .font(.subheadline)
                    .foregroundColor(.white)
            }
            HStack(alignment: .top, spacing: 12) {
                VStack(spacing: 12) {
                    Text("一般選考")
                        .font(.headline)
                        .fontWeight(.regular)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .center)
                    ForEach(Array(generalSteps.enumerated()), id: \.offset) { index, step in
                        SelectionStepCard(
                            stepNumber: index + 1,
                            mainText: step.mainText,
                            subText: step.subText
                        )
                    }
                }
                VStack(spacing: 12) {
                    Text("Percify")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .center)
                    ForEach(0..<5, id: \.self) { index in
                        if index < percifySteps.count {
                            SelectionStepCard(
                                stepNumber: index + 1,
                                mainText: percifySteps[index].mainText,
                                subText: percifySteps[index].subText
                            )
                        } else {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.ultraThinMaterial)
                                .opacity(0)
                                .frame(height: 75)
                        }
                    }
                }
            }
            Button(action: {
                showApplySheet = true
            }) {
                Text("今すぐ使ってエントリー")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.all, 8)
            }
            .buttonStyle(.glassProminent)
            .padding(.top, 12)
        }
        .listRowBackground(
            AnimatedMeshGradientBackground()
        )
        .padding()
        .padding(.vertical, 4)
    }
}

struct EventRecommendedPersonSection: View, Equatable {
    static func == (lhs: EventRecommendedPersonSection, rhs: EventRecommendedPersonSection) -> Bool {
        true // Static content
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "person.2")
                    .foregroundColor(.secondary)
                Text("こんな人におすすめ")
                    .font(.title2)
                    .fontWeight(.semibold)
            }
            Text("""
            ・自ら考え行動することが好きな人
            ・アイデアで価値を生み出したい人
            ・若いうちから責任ある仕事を任されたい人
            ・社会課題の解決に関心がある人
            ・柔軟な思考力と変化対応力に自信がある人
            ・チームでの協働を大切にする人
            """)
            .font(.subheadline)
            .foregroundColor(.primary)
        }
        .padding()
        .padding(.vertical, 4)
    }
}

struct EventVenueSection: View, Equatable {
    static func == (lhs: EventVenueSection, rhs: EventVenueSection) -> Bool {
        true // Static content
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "map")
                    .foregroundColor(.secondary)
                Text("会場")
                    .font(.title2)
                    .fontWeight(.semibold)
            }
            Text("""
            東京本社
            〒160-0023 東京都新宿区西新宿4-33-4
            Tel 03-6276-0401 / FAX 03-6893-6684
            """)
            .font(.subheadline)
            .foregroundColor(.primary)
        }
        .padding()
        .padding(.vertical, 4)
    }
}

struct EventCapacitySection: View, Equatable {
    static func == (lhs: EventCapacitySection, rhs: EventCapacitySection) -> Bool {
        true // Static content
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "exclamationmark.circle")
                    .foregroundColor(.secondary)
                Text("定員")
                    .font(.title2)
                    .fontWeight(.semibold)
            }
            Text("""
            10若干名
            定員に達し次第、予告なく募集を停止させていただくことがありますので、ご承知おきください。
            """)
            .font(.subheadline)
            .foregroundColor(.primary)
        }
        .padding()
        .padding(.vertical, 4)
    }
}

// MARK: - Selection Step Card (extracted for performance)

struct SelectionStepCard: View {
    let stepNumber: Int
    let mainText: String
    let subText: String?
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .opacity(0.4)
                .frame(height: 75)
            
            // Step number - top left
            Text("ステップ \(stepNumber)")
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(.white.opacity(0.8))
                .padding(12)
            
            // Content - bottom center
            VStack {
                Spacer()
                VStack(alignment: .leading, spacing: 2) {
                    Text(mainText)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                    if let subText = subText {
                        Text(subText)
                            .font(.caption2)
                            .fontWeight(.regular)
                            .foregroundColor(.white.opacity(0.7))
                            .multilineTextAlignment(.leading)
                    }
                }
                .padding(12)
            }
        }
    }
}

// MARK: - Main View (UI-only)

struct EventDetailsView: View {

    // Keep this constant simple & robust (no device model lookups)
    private var deviceCornerRadius: CGFloat { 46.0 }

    // UI State only
    @Environment(\.dismiss) private var dismiss
    @State private var isFavorited = false
    @State private var wantsShare = false
    @State private var showApplySheet = false
    @State private var showAppliedSheet = false
    @State private var hasApplied = false // purely local UI state
    @State private var selectedTab = "なにをやっているのか"
    @State private var selectedJobCategory = "IT職"
    @State private var animateChart = false
    @State private var gradientOffset: CGFloat = 0
    @State private var showRecruitmentDetails = false
    
    // Individually addressable content for each cell
    private let generalSelectionSteps: [SelectionStep] = [
        SelectionStep(mainText: "エントリーシート", subText: "書類の提出が必要"),
        SelectionStep(mainText: "ディスカッション", subText: "グループで実施"),
        SelectionStep(mainText: "一次面接", subText: "現場社員による"),
        SelectionStep(mainText: "二次面接", subText: "人事による"),
        SelectionStep(mainText: "最終面接", subText: "役員による")
    ]
    
    private let percifySelectionSteps: [SelectionStep] = [
        SelectionStep(mainText: "ディスカッション", subText: "グループで実施"),
        SelectionStep(mainText: "一次面接", subText: "現場社員による"),
        SelectionStep(mainText: "二次面接", subText: "人事＋社員座談会"),
        SelectionStep(mainText: "最終面接", subText: "役員による")
    ]
    
    // Chart data for projected salary background - initialized once with random values
    private let chartData: [Double] = {
        let numberOfPoints = 14
        let startValue: Double = 25.0
        let endValue: Double = 85.0
        let increment = (endValue - startValue) / Double(numberOfPoints - 1)
        
        // Generate random values once at initialization
        var values: [Double] = []
        for index in 0..<numberOfPoints {
            let baseValue = startValue + (increment * Double(index))
            // Add small random fluctuation (±3 points)
            let fluctuation = Double.random(in: -3...3)
            values.append(max(startValue, min(endValue, baseValue + fluctuation)))
        }
        return values
    }()
    
    // Cache screen width to avoid repeated lookups
    private let screenWidth = UIScreen.main.bounds.width
    
    // Cache feedback generator to avoid creating new instances
    private let lightFeedback = UIImpactFeedbackGenerator(style: .light)
    private let mediumFeedback = UIImpactFeedbackGenerator(style: .medium)

    let jobID: String
    let imageURL: URL?
    let eikenRequired: String
    let toeicRequired: String
    let companyLogo: String
    let title: String
    let businessName: String
    let stationName: String
    let jobDuration: String
    let roleKind: String
    let payHourly: String
    let payAdded: String

    // Fixed display order for sections
    private let sectionOrder: [JobSectionKind] = [
        .qualification, .description, .salary, .period,
        .shift, .weekdays, .benefits, .access, .flowAfterApply
    ]

    // MARK: - Placeholder data replacing backend JobsStore

    private var placeholderOverview: String {
        """
        【概要（プレースホルダー）】
        ここに求人の概要説明が入ります。ポジションの魅力、求める人物像、働く環境などを簡潔に記載してください。
        """
    }

    private var placeholderSections: [JobSectionKind: String] {
        [
            .top:
                """
                【主なお仕事（例）】
                ・接客対応、簡単なご案内
                ・レジ・ドリンク提供の補助
                ・バックヤードでの品出し、清掃 など
                """
        ]
    }

    // MARK: - Subviews (UI only)

    @ViewBuilder
    private func infoRowsView() -> some View {
        VStack(alignment: .leading, spacing: 6) {
            InfoRowView(icon: "building.2.fill", label: "会社名:", value: businessName)
            InfoRowView(icon: "safari.fill", label: "会社HP:", value: "www.orientalland.co.jp")
            InfoRowView(icon: "calendar", label: "設立年月:", value: "1960年7月11日")
            InfoRowView(icon: "map.fill", label: "本社住所:", value: "〒279-8511 千葉県浦安市美浜1丁目8番1号", labelLeadingPadding: -0.5)
            InfoRowView(icon: "yensign.bank.building.fill", label: "上場区分:", value: "東京証券取引所 プライム市場（証券コード：4661）", labelLeadingPadding: -1)
            InfoRowView(icon: "person.2.fill", label: "従業員数:", value: "約5,800名", iconLeadingPadding: -1, labelLeadingPadding: -2)
            InfoRowView(icon: "globe.asia.australia.fill", label: "事業内容:", value: "東京ディズニーリゾートの開発・運営", iconLeadingPadding: 1, labelLeadingPadding: 1)
            InfoRowView(icon: "person.fill", label: "代表者名:", value: "高橋 渉", iconLeadingPadding: 2, labelLeadingPadding: 1)
            InfoRowView(icon: "star.fill", label: "業種:", value: "ホスピタリティ・ツーリズム", iconLeadingPadding: 1)
        }
    }
    
    @ViewBuilder
    private func projectedSalaryView() -> some View {
        ZStack {
            // Chart background - wrapped for performance
            SalaryChartView(chartData: chartData, animateChart: animateChart)
            
            // Content on top
            HStack(alignment: .firstTextBaseline, spacing: 0) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("新卒年収")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .padding(.bottom, -4)
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(alignment: .bottom, spacing: 2) {
                            Text("320")
                                .fixedSize(horizontal: true, vertical: true)
                                .font(.title)
                                .fontWeight(.heavy)
                            Text("万円")
                                .font(.title3)
                                .fontWeight(.heavy)
                                .padding(.bottom, 3)
                        }
                        Text("000万円~")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()
                Image("Arrow")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40)
                    .offset(y: 35)
                    .opacity(0.3)
                Spacer()
                VStack(alignment: .trailing, spacing: 6) {
                    Text("30歳年収")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .padding(.bottom, -4)
                    VStack(alignment: .trailing, spacing: 2) {
                        HStack(alignment: .bottom, spacing: 2) {
                            Text("1,120")
                                .fixedSize(horizontal: true, vertical: true)
                                .font(.title)
                                .fontWeight(.heavy)
                            Text("万円")
                                .font(.title3)
                                .fontWeight(.heavy)
                                .padding(.bottom, 3)
                        }
                        Text("0,000万円~")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0)) {
                animateChart = true
            }
        }
    }

        
        @ViewBuilder
        private func overviewView() -> some View {
            VStack(alignment: .leading) {
                HStack(spacing: 6) {
                    Image(systemName: "info.circle.fill").foregroundStyle(Color.secondary)
                        .font(.caption)
                    Text("概要:").foregroundStyle(Color.secondary).fontWeight(.semibold).font(.caption)
                        .padding(.leading, 0.8)
                }
                .padding(.horizontal)
                .padding(.leading, 2)
                
                Text(placeholderOverview)
                    .foregroundColor(Color.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(nil)
                    .font(.caption)
                    .padding(.horizontal)
            }
            .padding(.top, -6)
    }

    @ViewBuilder
    private func tagsView() -> some View {
        HStack(alignment: .top, spacing: 6) {
            Image(systemName: "tag.fill").foregroundStyle(Color.secondary)
            VStack(alignment: .leading, spacing: 0) {
                Text("タグ")
                    .foregroundStyle(Color.secondary)
                    .fontWeight(.semibold)
                    .font(.body)
                    .frame(width: 54, alignment: .topLeading)

                TagsFlowLayout()
                    .padding(.top, 8)
                    .padding(.leading, -33)
            }
        }
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private func eventInfoListView() -> some View {
        VStack {
            HStack(alignment: .top, spacing: 6) {
                Image(systemName: "plus.circle").foregroundStyle(Color.secondary)
                Text("追加情報")
                    .foregroundStyle(Color.secondary)
                    .fontWeight(.semibold)
                    .font(.body)
                    //.padding(.top, -1)
            }
            .padding(.horizontal)
        }
        List {
            Section {
                EventOverviewSection()
            }
            Section {
                SelectionFlowSection(
                    generalSteps: generalSelectionSteps,
                    percifySteps: percifySelectionSteps,
                    showApplySheet: $showApplySheet
                )
            }
            Section {
                EventRecommendedPersonSection()
            }
            Section {
                EventVenueSection()
            }
            Section {
                EventCapacitySection()
            }
        }
        .padding(.top, -30)
        .scrollDisabled(true)
        .listSectionSpacing(.compact)
        .scrollContentBackground(.hidden)
        .background(Color.clear)
        .frame(minHeight: 2220)
        .padding(.bottom, -200)
    }
    
    @ViewBuilder
    private func scheduleCarouselView() -> some View {
        scheduleCarouselItem(index: 0)
    }
    
    @ViewBuilder
    private func scheduleCarouselItem(index: Int) -> some View {
        VStack {
            HStack(alignment: .top, spacing: 6) {
                Image(systemName: "calendar").foregroundStyle(Color.secondary)
                Text("日程")
                    .foregroundStyle(Color.secondary)
                    .fontWeight(.semibold)
                    .font(.body)
                    //.frame(width: 54, alignment: .topLeading)
                    .padding(.top, -1)
                Spacer()
            }
            .padding(.horizontal)
            List {
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("3月15日")
                            .font(.headline)
                        Text("新宿本社オフィス")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    HStack {
                        Image(systemName: "clock")
                        Text("あと14日")
                    }
                }
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("3月27日")
                            .font(.headline)
                        Text("新宿本社オフィス")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    HStack {
                        Image(systemName: "clock")
                        Text("あと28日")
                    }
                }
            }
            .frame(minHeight: 185)
            .padding(.top, -30)
            .scrollDisabled(true)
            .scrollContentBackground(.hidden)
            .background(Color.clear)
        }
    }
    
    private var scheduleImagePlaceholder: some View {
        RoundedRectangle(cornerRadius: 0, style: .continuous)
            .fill(Color.secondary.opacity(0.15))
            .frame(width: 200, height: 112.5)
            .shimmering()
    }
    
    @ViewBuilder
    private func imageCarouselView() -> some View {
        HStack(alignment: .top, spacing: 6) {
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .top, spacing: 6) {
                    Image(systemName: "photo.fill").foregroundStyle(Color.secondary)
                    Text("企業")
                        .foregroundStyle(Color.secondary)
                        .fontWeight(.semibold)
                        .font(.body)
                        .frame(width: 54, alignment: .topLeading)
                        .padding(.top, -1)
                }
                .padding(.horizontal)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(0..<5, id: \.self) { index in
                            carouselImageItem(index: index)
                                .padding(.leading, index == 0 ? 50 : 0)
                                .padding(.trailing, index == 5 ? 100 : 0)
                        }
                    }
                }
                .padding(.top, 8)
                .padding(.leading, -33)
                .padding(.trailing, -3)
            }
        }
        //.padding(.horizontal)
    }
    
    @ViewBuilder
    private func carouselImageItem(index: Int) -> some View {
        let imageURL = URL(string: "https://picsum.photos/seed/\(jobID)-\(index)/400/300")
        
        AsyncImage(url: imageURL) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: 160, height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .stroke(Color.secondary.opacity(0.2), lineWidth: 0.5)
                    )
            case .empty, .failure:
                carouselPlaceholder
            @unknown default:
                carouselPlaceholder
            }
        }
        .task(priority: .low) {
            // Limit loading priority to reduce concurrent load
        }
    }
    
    private var carouselPlaceholder: some View {
        RoundedRectangle(cornerRadius: 22, style: .continuous)
            .fill(Color.secondary.opacity(0.15))
            .frame(width: 160, height: 120)
            .shimmering()
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            //.overlay(
                //ProgressView()
                    //.controlSize(.regular)
            //)
    }

    private let allTabs: [String] = ["なにをやっているのか", "特別選考ルート", "仕事内容", "給与", "勤務時間、休日", "勤務地、転勤", "福利厚生", "選考ポイント", "同じ企業から"]
    
    @ViewBuilder
    private func tabPickerView() -> some View {
        VStack(spacing: 0) {
            tabPickerScrollView(tabs: allTabs)
            tabContentTabView(tabs: allTabs)
        }
    }
    
    @ViewBuilder
    private func tabPickerScrollView(tabs: [String]) -> some View {
        ScrollViewReader { proxy in
            tabPickerScrollContent(tabs: tabs)
                .onChange(of: selectedTab) { _, newTab in
                    scrollToTab(newTab, in: tabs, using: proxy)
                }
        }
    }
    
    private func scrollToTab(_ tab: String, in tabs: [String], using proxy: ScrollViewProxy) {
        if let index = tabs.firstIndex(of: tab) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                proxy.scrollTo("tab_\(index)", anchor: .center)
            }
        }
    }
    
    @ViewBuilder
    private func tabPickerScrollContent(tabs: [String]) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(Array(tabs.enumerated()), id: \.element) { index, tab in
                    tabButton(tab: tab, index: index)
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
    }
    
    @ViewBuilder
    private func tabButton(tab: String, index: Int) -> some View {
        let isSelected = selectedTab == tab
        Button {
            handleTabSelection(tab)
        } label: {
            tabButtonLabel(tab: tab, isSelected: isSelected)
        }
        .id("tab_\(index)")
    }
    
    private func handleTabSelection(_ tab: String) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            selectedTab = tab
        }
        lightFeedback.impactOccurred()
    }
    
    @ViewBuilder
    private func tabButtonLabel(tab: String, isSelected: Bool) -> some View {
        Text(tab)
            .font(.subheadline)
            .fontWeight(isSelected ? .semibold : .medium)
            .foregroundColor(isSelected ? .white : .primary)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(tabButtonBackground(isSelected: isSelected))
    }
    
    @ViewBuilder
    private func tabButtonBackground(isSelected: Bool) -> some View {
        Capsule()
            .fill(isSelected ? Color.accentColor : Color.secondary.opacity(0.15))
    }
    
    @ViewBuilder
    private func tabContentTabView(tabs: [String]) -> some View {
        TabView(selection: $selectedTab) {
            ForEach(tabs, id: \.self) { tab in
                tabContentForTab(tab)
                    .tag(tab)
                    .overlay(alignment: .leading) {
                        edgeTapArea(for: .previous, in: tabs)
                    }
                    .overlay(alignment: .trailing) {
                        edgeTapArea(for: .next, in: tabs)
                    }
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .frame(height: 700) // Fixed height for consistent layout
        .padding(.top, 10)
        .scrollDisabled(true)
        .onChange(of: selectedTab) { oldValue, newValue in
            handleTabChange(from: oldValue, to: newValue)
        }
    }
    
    private enum TabDirection {
        case previous, next
    }
    
    @ViewBuilder
    private func edgeTapArea(for direction: TabDirection, in tabs: [String]) -> some View {
        Rectangle()
            .fill(Color.clear)
            .frame(width: 80)
            .contentShape(Rectangle())
            .onTapGesture {
                handleEdgeTap(direction: direction, in: tabs)
            }
    }
    
    private func handleEdgeTap(direction: TabDirection, in tabs: [String]) {
        guard let currentIndex = tabs.firstIndex(of: selectedTab) else { return }
        
        let newIndex: Int
        switch direction {
        case .previous:
            newIndex = currentIndex - 1
        case .next:
            newIndex = currentIndex + 1
        }
        
        guard newIndex >= 0 && newIndex < tabs.count else { return }
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            selectedTab = tabs[newIndex]
        }
        lightFeedback.impactOccurred()
    }
    
    private func handleTabChange(from oldValue: String, to newValue: String) {
        if oldValue != newValue {
            lightFeedback.impactOccurred()
        }
    }
    
    
    @ViewBuilder
    private func tabContentForTab(_ tab: String) -> some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                switch tab {
                case "なにをやっているのか":
                    tab1Content()
                case "仕事内容":
                    tab2Content()
                case "給与":
                    tab3Content()
                case "勤務時間、休日":
                    tab4Content()
                case "勤務地、転勤":
                    tab5Content()
                case "福利厚生":
                    tab6Content()
                case "特別選考ルート":
                    tab7Content()
                case "選考ポイント":
                    tab8Content()
                case "同じ企業から":
                    tab9Content()
                default:
                    EmptyView()
                }
            }
        }
    }
    
    @ViewBuilder
    private func tabContentView() -> some View {
        switch selectedTab {
        case "なにをやっているのか":
            tab1Content()
        case "仕事内容":
            tab2Content()
        case "給与":
            tab3Content()
        case "勤務時間、休日":
            tab4Content()
        case "勤務地、転勤":
            tab5Content()
        case "福利厚生":
            tab6Content()
        case "特別選考ルート":
            tab7Content()
        case "選考ポイント":
            tab8Content()
        case "同じ企業から":
            tab9Content()
        default:
            EmptyView()
        }
    }
    
    // MARK: - Tab Content Views  HERE ARE THE TABS YAAAY
    
    // Helper to create simplified gradient headers
    @ViewBuilder
    private func gradientHeader(icon: String, color: Color) -> some View {
        ZStack {
            LinearGradient(
                colors: [color.opacity(0.2), color.opacity(0.0)],
                startPoint: .top,
                endPoint: .bottom
            )
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(.secondary.opacity(0.5))
        }
        .clipShape(UnevenRoundedRectangle(topLeadingRadius: 32, topTrailingRadius: 32))
        .frame(height: 160)
        .frame(height: 160)
    }
    
    @ViewBuilder
    private func tab1Content() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            GlassEffectContainer {
                VStack {
                    AsyncImage(url: URL(string: "https://www.recruit.olc.co.jp/person/images/interview01/photo-visual.jpg")) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(height: 160)
                                .clipped()
                                .clipShape(UnevenRoundedRectangle(topLeadingRadius: 32, topTrailingRadius: 32))
                        case .empty:
                            UnevenRoundedRectangle(topLeadingRadius: 32, topTrailingRadius: 32)
                                .fill(Color(.systemGray5))
                                .frame(height: 160)
                                .shimmering()
                        case .failure:
                            UnevenRoundedRectangle(topLeadingRadius: 32, topTrailingRadius: 32)
                                .fill(Color(.systemGray5))
                                .frame(height: 160)
                                .shimmering()
                        @unknown default:
                            UnevenRoundedRectangle(topLeadingRadius: 32, topTrailingRadius: 32)
                                .fill(Color(.systemGray5))
                                .frame(height: 160)
                                .shimmering()
                        }
                    }
                    .frame(height: 160)
                    
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("なにをやっているのか")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("弊社オリエンタルランド（OLC）は、東京ディズニーリゾート（TDR）を経営・運営する会社で、ディズニーのライセンスを受け、テーマパーク（ランド・シー）、ホテル、商業施設などを運営し、「夢と魔法」を提供しています。\n事業は単なるテーマパーク運営に留まらず、広告、物流、インフラ、商品開発、エンターテイメントなど多岐にわたり、「心の活力創造事業」を通じて人々に感動を提供することを使命としています。﻿")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .padding(.vertical, 4)
                    }
                    .padding(.bottom, 10)
                    .padding()
                }
            }
            .padding(.horizontal)
        }
    }
    
    @ViewBuilder
    private func tab2Content() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            GlassEffectContainer {
                VStack {
                    ZStack {
                        LinearGradient(
                            colors: [.cyan.opacity(0.2), .cyan.opacity(0.00)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        Image(systemName: "briefcase")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary.opacity(0.5))
                    }
                    .clipShape(UnevenRoundedRectangle(topLeadingRadius: 32, topTrailingRadius: 32))
                    .frame(height: 160)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("仕事内容")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("当社のIT・デジタルマネジメント職は、東京ディズニーリゾートの運営を支える情報システム基盤の企画・構築・運用を担う職種です。")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .padding(.vertical, 4)
                        Text("パーク運営、ゲストサービス、キャスト支援、施設管理、サプライチェーンなど、多岐にわたる事業領域に対し、最新のデジタル技術を用いた最適化・高度化を推進していただきます。主な業務には、業務分析に基づくシステム要件定義、アプリケーション開発プロジェクトのマネジメント、クラウド環境やネットワーク・セキュリティ基盤の整備、データ利活用基盤の企画・運用設計、AI・IoT領域の技術検証および導入支援などが含まれます。全社的なデジタルトランスフォーメーションを推進する中核として、事業価値向上と運営の効率化を支える重要な役割を担います。\nまた、社内外の関係者と連携し、東京ディズニーリゾートにおけるゲスト体験価値向上に資するIT戦略の立案・実行にも参画していただきます。専門的な技術知識に加え、論理的思考力、コミュニケーション能力、プロジェクト管理能力が求められる職種です。")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .padding(.bottom, 10)
                }
            }
            .padding(.horizontal)
        }
    }
    
    @ViewBuilder
    private func tab3Content() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            GlassEffectContainer {
                VStack {
                    gradientHeader(icon: "chart.bar.xaxis.ascending", color: .green)
                    VStack(alignment: .leading, spacing: 12) {
                        Text("給与")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("年収、手当、残業代、想定年収")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .padding(.vertical, 4)
                        HStack {//PAY BLOCKS
                            Text("想定年収")
                                .font(.headline)
                                .foregroundColor(.primary)
                            Spacer()
                            Text("540万円")
                                .font(.headline)
                                .foregroundColor(.primary)
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 22))
                        //PAY BLOCKS
                        //PAY BLOCKS
                        HStack {//PAY BLOCKS
                            Text("昇給制度")
                                .font(.headline)
                                .foregroundColor(.primary)
                            Spacer()
                            Text("あり、年2回")
                                .font(.headline)
                                .foregroundColor(.primary)
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 22))
                        //PAY BLOCKS
                        HStack {//PAY BLOCKS
                            Text("各種手当")
                                .font(.headline)
                                .foregroundColor(.primary)
                            Spacer()
                            Text("資格手当、交通費手当、住宅補助手当、語学研修手当、育児手当、その他")
                                .font(.headline)
                                .foregroundColor(.primary)
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 22))
                        HStack {//PAY BLOCKS
                            Text("残業代の有無")
                                .font(.headline)
                                .foregroundColor(.primary)
                            Spacer()
                            Text("あり")
                                .font(.headline)
                                .foregroundColor(.primary)
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 22))
                        //PAY BLOCKS
                        //PAY BLOCKS
                        //PAY BLOCKS
                        HStack {//PAY BLOCKS
                            Text("昨年度賞与実績")
                                .font(.headline)
                                .foregroundColor(.primary)
                            Spacer()
                            Text("3ヶ月")
                                .font(.headline)
                                .foregroundColor(.primary)
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 22))
                        HStack {//PAY BLOCKS
                            Text("全社平均年収")
                                .font(.headline)
                                .foregroundColor(.primary)
                            Spacer()
                            Text("450万円")
                                .font(.headline)
                                .foregroundColor(.primary)
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 22))
                    }
                    .padding()
                    //.padding(.bottom, 10)
                }
            }
            .padding(.horizontal)
        }
    }
    
    @ViewBuilder
    private func tab4Content() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            GlassEffectContainer {
                VStack {
                    gradientHeader(icon: "calendar", color: .pink)
                    VStack(alignment: .leading, spacing: 12) {
                        Text("勤務時間、休日")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("オリエンタルランドではワークライフバランスを重視した働き方ができます。")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .padding(.vertical, 4)
                        HStack {//PAY BLOCKS
                            Text("勤務時間")
                                .font(.headline)
                                .foregroundColor(.primary)
                            Spacer()
                            Text("9時~17時")
                                .font(.headline)
                                .foregroundColor(.primary)
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 22))
                        //PAY BLOCKS
                        HStack {//PAY BLOCKS
                            Text("休憩時間")
                                .font(.headline)
                                .foregroundColor(.primary)
                            Spacer()
                            Text("1時間")
                                .font(.headline)
                                .foregroundColor(.primary)
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 22))
                        //PAY BLOCKS
                        HStack {//PAY BLOCKS
                            Text("フレックスタイム制の有無")
                                .font(.headline)
                                .foregroundColor(.primary)
                            Spacer()
                            Text("あり")
                                .font(.headline)
                                .foregroundColor(.primary)
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 22))
                        //PAY BLOCKS
                        HStack {//PAY BLOCKS
                            Text("コアタイム")
                                .font(.headline)
                                .foregroundColor(.primary)
                            Spacer()
                            Text("あり")
                                .font(.headline)
                                .foregroundColor(.primary)
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 22))
                        //PAY BLOCKS
                        HStack {//PAY BLOCKS
                            Text("休日制度")
                                .font(.headline)
                                .foregroundColor(.primary)
                            Spacer()
                            Text("完全週休二日制")
                                .font(.headline)
                                .foregroundColor(.primary)
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 22))
                        //PAY BLOCKS
                        HStack {//PAY BLOCKS
                            Text("年間休日日数")
                                .font(.headline)
                                .foregroundColor(.primary)
                            Spacer()
                            Text("125日")
                                .font(.headline)
                                .foregroundColor(.primary)
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 22))
                        //PAY BLOCKS
                    }
                    .padding()
                    //.padding(.bottom, 10)
                }
            }
            .padding(.horizontal)
        }
    }
    
    @ViewBuilder
    private func tab5Content() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            GlassEffectContainer {
                VStack {
                    gradientHeader(icon: "map", color: .orange)
                    VStack(alignment: .leading, spacing: 12) {
                        Text("勤務地、転勤")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("千葉県舞浜市を拠点に、夢と希望を届けています。")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .padding(.vertical, 4)
                        HStack {//PAY BLOCKS
                            Text("勤務地")
                                .font(.headline)
                                .foregroundColor(.primary)
                            Spacer()
                            Text("千葉県舞浜市")
                                .font(.headline)
                                .foregroundColor(.primary)
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 22))
                        //PAY BLOCKS
                        HStack {//PAY BLOCKS
                            Text("勤務地")
                                .font(.headline)
                                .foregroundColor(.primary)
                            Spacer()
                            Text("カリフォルニア州アナハイム")
                                .font(.headline)
                                .foregroundColor(.primary)
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 22))
                        //PAY BLOCKS
                        HStack {//PAY BLOCKS
                            Text("転勤")
                                .font(.headline)
                                .foregroundColor(.primary)
                            Spacer()
                            Text("なし")
                                .font(.headline)
                                .foregroundColor(.primary)
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 22))
                        //PAY BLOCKS
                    }
                    .padding()
                    //.padding(.bottom, 10)
                }
            }
            .padding(.horizontal)
        }
    }
    
    @ViewBuilder
    private func tab6Content() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            GlassEffectContainer {
                VStack {
                    gradientHeader(icon: "heart", color: .purple)
                    VStack(alignment: .leading, spacing: 12) {
                        Text("福利厚生")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("当社では、社員一人ひとりが安心して長期的に能力を発揮できるよう、充実した福利厚生制度を整備しています。各種社会保険を完備しているほか、住宅関連制度や財産形成支援制度、退職金制度など、生活基盤を安定的に支える仕組みを用意しています。")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .padding(.vertical, 4)
                        Text("また、育児・介護との両立を支援するための各種休暇制度や短時間勤務制度、在宅勤務を含む柔軟な働き方を可能とする制度を導入しており、ライフステージの変化に応じた就業継続を支援しています。年次有給休暇に加え、リフレッシュ休暇などの特別休暇制度も整備されています。\nさらに、社員の自己成長を支援する研修・教育制度や資格取得支援制度を設け、専門性の向上やキャリア形成を後押ししています。東京ディズニーリゾート関連施設の利用優遇など、当社ならではの福利厚生も充実しており、働きがいと働きやすさを両立できる環境を提供しています。")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .padding(.bottom, 10)
                }
            }
            .padding(.horizontal)
        }
    }
    
    @ViewBuilder
    private func tab7Content() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            GlassEffectContainer {
                VStack {
                    gradientHeader(icon: "star", color: .yellow)
                        .frame(height: 140)
                    VStack(alignment: .center, spacing: 12) {
                        Text("ライバルよりも\n一歩先に、夢の企業へ。\nPercify特別選考なら。")
                            .font(.title2)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        Text("株式会社オリエンタルランドは、Percify特別選考が利用可能な企業です。")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.vertical, 14)
                    }
                    HStack {
                        Text("一般ルート")
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text("Percify特別\n選考")
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.accentColor)
                            .multilineTextAlignment(.center)
                    }
                    .frame(width: screenWidth * 0.65)
                    VStack(spacing: 12) {
                        HStack(spacing: 26) {//ROW
                            VStack {
                                RoundedRectangle(cornerRadius: 16)
                                    .frame(height: 56)
                                    .foregroundColor(Color.white)
                                    .shadow(color: Color.black.opacity(0.1), radius: 7, x: 0, y: 0)
                                    .overlay(
                                        Text("エントリーシート")
                                            .font(.callout)
                                            .fontWeight(.regular)
                                    )
                            }
                            .frame(width: screenWidth * 0.38)
                            VStack {
                                RoundedRectangle(cornerRadius: 16)
                                    .frame(height: 56)
                                    .foregroundColor(Color.white)
                                    //.shadow(color: Color.black.opacity(0.1), radius: 7, x: 0, y: 0)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(style: StrokeStyle(lineWidth: 2, dash: [5, 3]))
                                            .foregroundColor(.accent)
                                    )
                                    .overlay(
                                        Text("書類選考免除")
                                            .font(.callout)
                                            .fontWeight(.semibold)
                                            .foregroundStyle(.accent)
                                    )
                            }
                            .frame(width: screenWidth * 0.38)
                        }//ROW
                        HStack {
                            Image(systemName: "arrow.down")
                                .foregroundStyle(.secondary)
                            Spacer()
                            Image(systemName: "arrow.down")
                                .fontWeight(.semibold)
                                .foregroundStyle(Color.accentColor)
                        }
                        .frame(width: screenWidth * 0.5)
                        .padding(.vertical, -6)
                        HStack(spacing: 26) {//ROW
                            VStack {
                                RoundedRectangle(cornerRadius: 16)
                                    .frame(height: 56)
                                    .foregroundColor(Color.white)
                                    .shadow(color: Color.black.opacity(0.1), radius: 7, x: 0, y: 0)
                                    .overlay(
                                        Text("一次面接")
                                            .font(.callout)
                                            .fontWeight(.regular)
                                    )
                            }
                            .frame(width: screenWidth * 0.38)
                            VStack {
                                RoundedRectangle(cornerRadius: 16)
                                    .frame(height: 56)
                                    .foregroundColor(Color.white)
                                    .shadow(color: Color.black.opacity(0.1), radius: 7, x: 0, y: 0)
                                    .overlay(
                                        Text("一次面接")
                                            .font(.callout)
                                            .fontWeight(.regular)
                                    )
                            }
                            .frame(width: screenWidth * 0.38)
                        }//ROW
                        HStack {
                            Image(systemName: "arrow.down")
                                .foregroundStyle(.secondary)
                            Spacer()
                            Image(systemName: "arrow.down")
                                .fontWeight(.semibold)
                                .foregroundStyle(Color.accentColor)
                        }
                        .frame(width: screenWidth * 0.5)
                        .padding(.vertical, -6)
                        HStack(spacing: 26) {//ROW
                            VStack {
                                RoundedRectangle(cornerRadius: 16)
                                    .frame(height: 56)
                                    .foregroundColor(Color.white)
                                    .shadow(color: Color.black.opacity(0.1), radius: 7, x: 0, y: 0)
                                    .overlay(
                                        Text("二次面接")
                                            .font(.callout)
                                            .fontWeight(.regular)
                                    )
                            }
                            .frame(width: screenWidth * 0.38)
                            VStack {
                                RoundedRectangle(cornerRadius: 16)
                                    .frame(height: 56)
                                    .foregroundColor(Color.white)
                                    .shadow(color: Color.black.opacity(0.1), radius: 7, x: 0, y: 0)
                                    .overlay(
                                        Text("二次面接")
                                            .font(.callout)
                                            .fontWeight(.regular)
                                    )
                            }
                            .frame(width: screenWidth * 0.38)
                        }//ROW
                        HStack {
                            Image(systemName: "arrow.down")
                                .foregroundStyle(.secondary)
                            Spacer()
                            Image(systemName: "arrow.down")
                                .fontWeight(.semibold)
                                .foregroundStyle(Color.accentColor)
                        }
                        .frame(width: screenWidth * 0.5)
                        .padding(.vertical, -6)
                        HStack(spacing: 26) {//ROW
                            VStack {
                                RoundedRectangle(cornerRadius: 16)
                                    .frame(height: 56)
                                    .foregroundColor(Color.white)
                                    .shadow(color: Color.black.opacity(0.1), radius: 7, x: 0, y: 0)
                                    .overlay(
                                        Text("サマーインターン")
                                            .font(.callout)
                                            .fontWeight(.regular)
                                    )
                            }
                            .frame(width: screenWidth * 0.38)
                            VStack {
                                RoundedRectangle(cornerRadius: 16)
                                    .frame(height: 56)
                                    .foregroundColor(Color.accentColor)
                                    .shadow(color: Color.purple.opacity(0.4), radius: 7, x: 0, y: 0)
                                    .overlay(
                                        Text("サマーインターン")
                                            .font(.callout)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.white)
                                    )
                            }
                            .frame(width: screenWidth * 0.38)
                        }//ROW
                    }
                }
                .padding(.bottom, 20)
            }
            .padding(.horizontal)
        }
    }
    
    @ViewBuilder
    private func tab8Content() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            GlassEffectContainer {
                VStack {
                    gradientHeader(icon: "star.bubble", color: .blue)
                    VStack(alignment: .leading, spacing: 12) {
                        Text("企業からの選考ポイント")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("オリエンタルランド株式会社での、夢のポジションを掴むには？")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .padding(.vertical, 4)
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {//PAY BLOCKS
                                Text("協調性")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Spacer()
                            }
                            Text("技術的な知識や専門性だけでなく、周囲と協力しながら物事を進められる協調性を重視しています。")
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 22))
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {//PAY BLOCKS
                                Text("コラボレーション")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Spacer()
                            }
                            Text("相手の立場や意図を正確に理解し、自身の考えを論理的かつ丁寧に伝えられるコミュニケーション力を期待しています。")
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 22))
                    }
                    .padding()
                    //.padding(.bottom, 10)
                }
            }
            .padding(.horizontal)
        }
    }
    
    @ViewBuilder
    private func tab9Content() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            GlassEffectContainer {
                VStack(alignment: .leading, spacing: 12) {
                    Rectangle()
                        .frame(height: 1)
                        .opacity(0.0)
                        
                    Text("オリエンタルランド株式会社からの他のポジション")
                        .font(.title2)
                        .fontWeight(.bold)
                        .fixedSize(horizontal: false, vertical: true)
                    VStack {
                        Spacer()
                        Spacer()
                        HStack {
                            Spacer()
                            ProgressView()
                                .controlSize(.large)
                                .padding()
                            Spacer()
                        }
                        HStack {
                            Spacer()
                            ProgressView()
                                .controlSize(.large)
                                .padding()
                            Spacer()
                        }
                        HStack {
                            Spacer()
                            ProgressView()
                                .controlSize(.large)
                                .padding()
                            Spacer()
                        }
                        Spacer()
                    }
                }
                .padding()
            }
            .padding(.horizontal)
        }
    }

    
    // MARK: - Helper Views for Tab Content
    
    // All helper views removed - placeholder tabs don't need them
    
    @ViewBuilder
    private func sectionsView() -> some View {
        ForEach(sectionOrder, id: \.self) { kind in
            if let content = placeholderSections[kind], !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                JobSectionView(kind: kind, content: content)
            }
        }
    }

    @ViewBuilder
    private func disclaimersCard() -> some View {
        GlassEffectContainer {
            VStack(alignment: .leading, spacing: 8) {
                Text("免責事項")
                    .foregroundStyle(.primary)
                    .font(.headline)
                    .padding(.horizontal)
                    .lineLimit(1)
                    .padding(.bottom, 2)

                Text("""
                本ページの求人情報は、求人広告主（\(businessName)）から提供された内容を基に掲載しています。当社は情報の正確性・最新性・完全性を保証しません。応募・面接・雇用契約等は利用者と求人広告主の間で直接行われます。利用者は自己の判断と責任で本サービスをご利用ください。

                英検®は公益財団法人日本英語検定協会の登録商標です。TOEIC®、TOEFL®はETSの登録商標です。IELTS®はケンブリッジ大学英語検定機構、British Council、IDP Education Australiaの登録商標です。本サービスは各団体の承認・提携を受けたものではありません。
                """)
                .foregroundStyle(.secondary)
                .font(.caption2)
                .padding(.horizontal)
            }
            //.padding(.vertical, 30)
        }
        .padding(.horizontal)
    }

    @ViewBuilder
    private func applyPromptCard() -> some View {
        GlassEffectContainer {
            HStack(alignment: .center) {
                VStack(alignment: .leading) {
                    Text("全てよさそうですか?")
                        .foregroundStyle(.secondary)
                        .font(.headline)
                        .lineLimit(1)

                    Text("応募は簡単です。")
                        .foregroundStyle(.primary)
                        .font(.headline)
                        .lineLimit(1)
                }
                .padding(.top, 15)
                Spacer()
                Image(systemName: "chevron.down.circle.fill")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .foregroundColor(.accentColor)
                    .padding(.top, 15)
                    .symbolEffect(.wiggle, options: .repeat(.periodic(delay: 0.9)))
            }
            //.frame(height: 100)
            .padding(.bottom, 15)
        }
        .padding(.horizontal)
        .padding(.top, 15)
    }

    @ViewBuilder//HERE IS THE WHOLE LAYOUT!!!
    private func mainDetails() -> some View {
        HStack(alignment: .top, spacing: 24) {
            VStack(alignment: .leading, spacing: 12) {
                projectedSalaryView()
                    .padding()
                Divider()
                    .padding(.horizontal)
                    .padding(.top, -20)
                HStack(alignment: .top, spacing: 6) {
                    Image(systemName: "info.circle").foregroundStyle(Color.secondary)
                    Text("このイベントについて")
                        .foregroundStyle(Color.secondary)
                        .fontWeight(.semibold)
                        .font(.body)
                        .padding(.top, -1)
                }
                .padding(.horizontal)
                titleText
                    .padding(.bottom, 5)
                    .padding(.top, 55)
                scheduleCarouselView()
                    .padding(.bottom, 20)
                eventInfoListView()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .offset(y: -130)
        }
    }

    // MARK: - Bottom bar content (UI-only)

    @ViewBuilder
    private func bottomBar() -> some View {
        GlassEffectContainer {
            VStack {
                HStack {
                    bottomBarPayInfo
                    Spacer()
                    bottomBarButtons
                }
                .padding(.horizontal, 19)
                .offset(y: 13)
                .padding(5)
                .padding(.bottom, 23)
            }
            .frame(height: screenWidth * (isMaxOrPlusIPhone ? 0.32 : 0.34))
        }
        .clipShape(RoundedRectangle(cornerRadius: deviceCornerRadius, style: .continuous))
        .padding(.horizontal, 15)
        .padding(.bottom, -20)
    }
    
    private var bottomBarPayInfo: some View {
        VStack(alignment: .leading, spacing: 4) {
            hourlyPayLabel
            formattedPayAmount
            payBonusLabel
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var hourlyPayLabel: some View {
        Text("時給")
            .font(.body)
            .fontWeight(.medium)
            .foregroundColor(.white.opacity(0.5))
            .padding(.bottom, 0.5)
    }
    
    private var formattedPayAmount: some View {
        let payText: Text = {
            if let number = Int(payHourly.filter({ $0.isNumber })) {
                return Text("¥\(NumberFormatter.localizedString(from: NSNumber(value: number), number: .decimal))")
            } else {
                return Text(payHourly)
            }
        }()
        
        return payText
            .font(.largeTitle)
            .fontWeight(.bold)
            .fontDesign(.rounded)
            .foregroundColor(.white)
            .lineLimit(1)
            .truncationMode(.tail)
            .padding(.trailing, -4)
    }
    
    private var payBonusLabel: some View {
        HStack {
            Text("給与プラス")
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(.accentColor)
                .fixedSize()
                .lineLimit(2)
                .padding(.top, 0.5)
                .padding(.trailing, -8)
            bonusAmountBadge
        }
    }
    
    private var bonusAmountBadge: some View {
        HStack {
            Text("¥\(payAdded)").padding(.trailing, -2)
            Image(systemName: "plus.circle.fill")
        }
        .font(.body)
        .fontWeight(.bold)
        .fontDesign(.rounded)
        .foregroundColor(.accentColor)
        .padding(.vertical, 2)
        .padding(.horizontal, 8)
        .padding(.trailing, -5)
        .fixedSize()
        .lineLimit(1)
    }
    
    private var bottomBarButtons: some View {
        VStack(alignment: .trailing) {
            favoriteButton
            applyButton
        }
        .padding(.trailing, -3)
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
    
    private var favoriteButton: some View {
        Button {
            isFavorited.toggle()
            mediumFeedback.impactOccurred()
        } label: {
            Image(systemName: isFavorited ? "heart.fill" : "heart")
                .font(.title2)
                .fontWeight(.regular)
                .foregroundStyle(isFavorited ? Color.pink : Color.gray)
        }
        .padding(8)
        .background(.ultraThinMaterial, in: Circle())
        .padding(.trailing, 6)
        .padding(.bottom, 7)
    }
    
    private var applyButton: some View {
        Button {
            mediumFeedback.impactOccurred()
            if hasApplied { showAppliedSheet = true } else { showApplySheet = true }
        } label: {
            Text(hasApplied ? "進捗を確認" : "今すぐ応募")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.black)
                .fixedSize()
                .padding(.vertical, 10)
                .padding(.horizontal, 22)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.accentColor)
                )
        }
    }

    // MARK: - Body Helper Views
    
    private var mainScrollView: some View {
        ScrollView {
            VStack {
                ParallaxHeaderView(imageURL: imageURL, height: 230)
                    .overlay(alignment: .bottom) {
                        VariableBlurView(maxBlurRadius: 16, direction: .blurredBottomClearTop)
                            .frame(height: 100)
                    }.ignoresSafeArea()
                    .overlay(
                        LinearGradient(colors: [Color.clear, Color.clear, Color(UIColor.systemGroupedBackground)],
                                                startPoint: .top,
                                                endPoint: .bottom
                                            ))
                companyHeaderSection
                mainDetails()
                Spacer()
            }
            .padding(.bottom, 12)
        }
        .overlay(alignment: .top) { topOverlayGradient }
    }
    
    private var companyHeaderSection: some View {
        VStack {
            companyLogoRow
            VStack(alignment: .leading, spacing: 16) {
            }
        }
    }
    
    private var companyLogoRow: some View {
        HStack {
            Button {
                showRecruitmentDetails = true
            } label: {
                HStack {
                    Image(companyLogo)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color.gray.opacity(0.25), lineWidth: 0.15)
                        )
                    VStack(alignment: .leading, spacing: 4) {
                        Text("コンサルティング・金融")
                            .font(.caption)
                            .fixedSize(horizontal: true, vertical: false)
                            .foregroundColor(.primary)
                            .padding(.bottom, -2)
                        Text(String(businessName.prefix(15)))
                            .font(.title2)
                            .fontWeight(.bold)
                            .fixedSize(horizontal: true, vertical: false)
                            .lineLimit(1)
                        HStack {
                            Image("LogoSmall")
                                .resizable()
                                .colorMultiply(.purple)
                                .scaledToFit()
                                .frame(width: 14, height: 25)
                            Text("Percify特別選考ルートがあります")
                                .fixedSize(horizontal: true, vertical: false)
                                .font(.caption2)
                                .foregroundColor(.purple)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 1)
                        .background(Color.purple.opacity(0.15))
                        .clipShape(Capsule())
                        .padding(.top, 4)
                    }
                    .padding(.leading, 6)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary.opacity(0.6))
                }
            }
            .buttonStyle(.plain)
            .padding()
            .glassEffect(.clear.interactive(), in: RoundedRectangle(cornerRadius: 44))
            .shadow(
                            color: Color.black.opacity(0.1), // Use opacity for a softer look
                            radius: 12,                     // Large radius for a soft blur
                            x: 0,                           // No horizontal offset
                            y: 3                           // Slight vertical offset for a "lifted" look
                        )
            .padding(.all, 6)
            .offset(x: 0, y: -110)
            .padding(.horizontal, 9)
            .frame(maxWidth: UIScreen.main.bounds.width * 1.0, alignment: .center)
            .fullScreenCover(isPresented: $showRecruitmentDetails) {
                NavigationStack {
                    RecruitmentDetailsView(
                        jobID: jobID,
                        imageURL: imageURL,
                        eikenRequired: eikenRequired,
                        toeicRequired: toeicRequired,
                        companyLogo: companyLogo,
                        title: title,
                        businessName: businessName,
                        stationName: stationName,
                        jobDuration: jobDuration,
                        roleKind: roleKind,
                        payHourly: payHourly,
                        payAdded: payAdded
                    )
                }
            }
            //Spacer()
        }
    }
    
    private var badgeText: some View {
        HStack {
            Image("LogoSmall")
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 25)
            Text("Percify特別選考ルート")
                .fixedSize(horizontal: true, vertical: false)
        }
            .font(.headline)
            .lineLimit(1)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                LinearGradient(colors: [.purple, .purple], startPoint: .top, endPoint: .bottom)
                    .overlay(
                        LinearGradient(colors: [.clear, .white.opacity(0.2)], startPoint: .bottom, endPoint: .top)
                    )
                    .clipShape(Capsule())
                    .overlay(
                        Capsule()
                            .strokeBorder(Color.white.opacity(0.4), lineWidth: 0.5)
                    )
            )
            .foregroundStyle(.white)
    }
    
    private var titleText: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top)
            Text("イベント種別: インターン")
                .font(.headline)
                .foregroundColor(.accentColor)
                .padding(.horizontal, 8)
                .padding(.all, 6)
                .background(Color.purple.opacity(0.15))
                .clipShape(Capsule())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
        .padding(.bottom, 16)
        .padding(.top, -70)
    }
    
    private var topOverlayGradient: some View {
        Rectangle()
            .fill(LinearGradient(
                gradient: Gradient(colors: [
                    Color(.systemGroupedBackground).opacity(0.6),
                    Color.clear
                ]),
                startPoint: .top,
                endPoint: .bottom
            ))
            .frame(height: 140)
            .ignoresSafeArea(edges: .top)
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            leadingToolbarButton
        }
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                // Open company page action
                // TODO: Add navigation to company page
            } label: {
                HStack {
                    Text("企業ページ")
                    Image(systemName: "arrow.up.right")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                }
            }
        }
        ToolbarItemGroup(placement: .bottomBar) {
            bottomToolbarGroup
        }
    }
    
    private var leadingToolbarButton: some View {
        Button(action: { dismiss() }) {
            Label("Done", systemImage: "chevron.backward")
        }
    }
    
    private var trailingToolbarButton: some View {
        Menu {
            Button {
                selectedJobCategory = "IT職"
            } label: {
                Label("IT職", systemImage: selectedJobCategory == "IT職" ? "checkmark" : "")
            }
            Button {
                selectedJobCategory = "総合職"
            } label: {
                Label("総合職", systemImage: selectedJobCategory == "総合職" ? "checkmark" : "")
            }
            Button {
                selectedJobCategory = "一般職"
            } label: {
                Label("一般職", systemImage: selectedJobCategory == "一般職" ? "checkmark" : "")
            }
            Button {
                selectedJobCategory = "デザイン職"
            } label: {
                Label("デザイン職", systemImage: selectedJobCategory == "デザイン職" ? "checkmark" : "")
            }
            Button {
                selectedJobCategory = "パフォーマンス職"
            } label: {
                Label("パフォーマンス職", systemImage: selectedJobCategory == "パフォーマンス職" ? "checkmark" : "")
            }
        } label: {
            HStack(spacing: 4) {
                Text(selectedJobCategory)
                Image(systemName: "chevron.down")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    @ViewBuilder
    private var bottomToolbarGroup: some View {
        Button(action: {}) {
            Label("Done", systemImage: "heart")
        }
        Spacer()
        entryButton
    }
    
    private var entryButton: some View {
        Button(action: {}) {
            Label {
                Text("今すぐエントリー")
                    .font(.headline)
            } icon: {
                Image(systemName: " ")
            }
        }
        .buttonStyle(.glassProminent)
    }
    
    private var applySheetContent: some View {
        VStack(spacing: 16) {
            Text("応募フォーム（プレースホルダー）")
                .font(.title3)
                .bold()
            Text("ここに応募用のUIを実装してください。")
                .foregroundStyle(.secondary)
            Button("閉じる") {
                showApplySheet = false
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .presentationDetents([.fraction(0.44), .large])
    }
    
    private var appliedSheetContent: some View {
        VStack(spacing: 16) {
            Text("応募状況（プレースホルダー）")
                .font(.title3)
                .bold()
            Text("応募済みの進捗を表示する画面をここに。")
                .foregroundStyle(.secondary)
            Button("閉じる") {
                showAppliedSheet = false
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .presentationDetents([.medium, .large])
    }
    
    // MARK: - Label Chip Helper
    
    private func labelChip(text: String, symbol: String? = nil, chipColor: Color? = nil) -> some View {
        HStack(spacing: 4) {
            if let symbol = symbol {
                Image(systemName: symbol)
                    .font(.caption.weight(.medium))
                    .foregroundColor(.white)
            }
            Text(text)
                .font(.subheadline.weight(.medium))
                .foregroundColor(.white)
        }
        .fixedSize(horizontal: true, vertical: true)
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(
            Group {
                if let chipColor = chipColor {
                    Capsule()
                        .fill(chipColor.opacity(0.85))
                        .overlay(
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [.black.opacity(0.0), .black.opacity(0.0)],
                                        startPoint: .bottom,
                                        endPoint: .top
                                    )
                                )
                        )
                        .overlay(
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [.clear, .white.opacity(0.3)],
                                        startPoint: .bottom,
                                        endPoint: .top
                                    )
                                )
                        )
                } else {
                    Capsule().fill(.thinMaterial)
                        .overlay(
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [.clear, .white],
                                        startPoint: .bottom,
                                        endPoint: .top
                                    )
                                )
                        )
                }
            }
        )
        .overlay(
            Capsule()
                .strokeBorder(.white.opacity(0.5), lineWidth: 1)
        )
        .foregroundStyle(chipColor ?? .black)
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            mainScrollView
        .navigationTitle("このイベントの詳細")
        .navigationSubtitle(title)
        .navigationBarTitleDisplayMode(.inline)
                .toolbar { toolbarContent }
            .sheet(isPresented: $showApplySheet) {
            // Simple “deadline” indicator (static placeholder)

            // Share button (uses native ShareLink)

            // Placeholder apply step
            applySheetContent
        }
        .sheet(isPresented: $showAppliedSheet) {
            // Placeholder applied progress
            appliedSheetContent
        }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
        }
    }
}

// MARK: - Parallax Header (kept, no backend)

struct ParallaxHeaderView2: View {
    let imageURL: URL?
    let height: CGFloat
    
    // Cache screen width
    private let screenWidth = UIScreen.main.bounds.width

    var body: some View {
        GeometryReader { geo in
            parallaxContent(for: geo)
        }
        .frame(height: height)
        .drawingGroup()
    }
    
    private func parallaxContent(for geo: GeometryProxy) -> some View {
        let minY: CGFloat = geo.frame(in: .global).minY
        let extraWidth: CGFloat = (minY > 0 ? minY * screenWidth / 300 : 0)
        let frameHeight: CGFloat = height + (minY > 0 ? minY : 0)
        
        return ZStack {
            if let imageURL {
                imageContent(
                    url: imageURL,
                    baseWidth: screenWidth,
                    extraWidth: extraWidth,
                    frameHeight: frameHeight
                )
            } else {
                placeholderContent(
                    baseWidth: screenWidth,
                    extraWidth: extraWidth,
                    frameHeight: frameHeight
                )
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .offset(y: (minY > 0 ? -minY : 0))
    }
    
    @ViewBuilder
    private func imageContent(url: URL, baseWidth: CGFloat, extraWidth: CGFloat, frameHeight: CGFloat) -> some View {
        AsyncImage(url: url) { phase in
            imagePhaseView(
                phase: phase,
                baseWidth: baseWidth,
                extraWidth: extraWidth,
                frameHeight: frameHeight
            )
        }
    }
    
    @ViewBuilder
    private func imagePhaseView(phase: AsyncImagePhase, baseWidth: CGFloat, extraWidth: CGFloat, frameHeight: CGFloat) -> some View {
        switch phase {
        case .success(let image):
            successImageView(
                image: image,
                baseWidth: baseWidth,
                extraWidth: extraWidth,
                frameHeight: frameHeight
            )
        case .empty, .failure:
            placeholderContent(
                baseWidth: baseWidth,
                extraWidth: extraWidth,
                frameHeight: frameHeight
            )
        @unknown default:
            placeholderContent(
                baseWidth: baseWidth,
                extraWidth: extraWidth,
                frameHeight: frameHeight
            )
        }
    }
    
    private func successImageView(image: Image, baseWidth: CGFloat, extraWidth: CGFloat, frameHeight: CGFloat) -> some View {
        image
            .resizable()
            .scaledToFill()
            .aspectRatio(4/3, contentMode: .fill)
            .frame(width: baseWidth + extraWidth, height: frameHeight)
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: 0))
            .ignoresSafeArea(edges: .top)
            .overlay(alignment: .top) {
                VariableBlurView(maxBlurRadius: 4, direction: .blurredTopClearBottom)
                    .frame(height: 100)
            }.ignoresSafeArea()
            .offset(x: -(extraWidth / 2))
    }
    
    private func placeholderContent(baseWidth: CGFloat, extraWidth: CGFloat, frameHeight: CGFloat) -> some View {
        placeholder
            .frame(width: baseWidth + extraWidth, height: frameHeight)
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: 0))
            .ignoresSafeArea(edges: .top)
            .offset(x: -(extraWidth / 2))
    }

    private var placeholder: some View {
        ZStack {
            Color(.systemGray5)
                .shimmering()
            VStack {
                ProgressView()
                    .controlSize(.large)
            }
        }
        .aspectRatio(4/3, contentMode: .fill)
        .shimmeringPlaceholder()
    }
}

// MARK: - Section Card

struct JobSectionView2: View {
    let kind: JobSectionKind
    let content: String
    var body: some View {
        GlassEffectContainer {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: kind.icon)
                        .font(.title2)
                        .foregroundColor(kind.iconColor)
                    Text(kind.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .lineLimit(1)
                }
                .padding(.bottom, 2)

                Text(content)
                    .foregroundColor(Color.primary)
                    .font(.body)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(nil)
                    .padding(.top, 1)
            }
            .padding()
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
    }
}

// MARK: - Flow Layout (unchanged, UI-only)

struct FlowLayout2<Data: RandomAccessCollection, Content: View>: View where Data.Element: Hashable {
    let tags: Data
    let content: (Data.Element) -> Content
    @State private var totalHeight = CGFloat.zero

    init(tags: Data, @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.tags = tags
        self.content = content
    }
    var body: some View {
        GeometryReader { geometry in
            self.generateContent(in: geometry)
        }
        .frame(height: totalHeight)
    }
    private func generateContent(in geo: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero
        return ZStack(alignment: .topLeading) {
            ForEach(Array(tags), id: \.self) { tag in
                content(tag)
                    .padding(.horizontal, 6).padding(.vertical, 4)
                    .alignmentGuide(.leading, computeValue: { d in
                        if abs(width - d.width) > geo.size.width {
                            width = 0
                            height -= d.height
                        }
                        let result = width
                        if tag == tags.last {
                            width = 0
                        } else {
                            width -= d.width
                        }
                        return result
                    })
                    .alignmentGuide(.top, computeValue: { _ in
                        let result = height
                        if tag == tags.last {
                            height = 0
                        }
                        return result
                    })
            }
        }
        .background(viewHeightReader($totalHeight))
    }
    private func viewHeightReader(_ binding: Binding<CGFloat>) -> some View {
        GeometryReader { geo in
            Color.clear
                .preference(key: ViewHeightKey.self, value: geo.size.height)
        }
        .onPreferenceChange(ViewHeightKey.self) { value in
            binding.wrappedValue = value
        }
    }
}
private struct ViewHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

// MARK: - Animated Mesh Gradient Background

struct AnimatedMeshGradientBackground: View {
    private let colors: [Color] = [
        Color(red: 1.00, green: 0.42, blue: 0.42),
        Color(red: 1.00, green: 0.55, blue: 0.00),
        Color(red: 1.00, green: 0.27, blue: 0.00),
        
        Color(red: 1.00, green: 0.41, blue: 0.71),
        Color(red: 0.85, green: 0.44, blue: 0.84),
        Color(red: 0.54, green: 0.17, blue: 0.89),
        
        Color(red: 0.29, green: 0.00, blue: 0.51),
        Color(red: 0.00, green: 0.00, blue: 0.55),
        Color(red: 0.10, green: 0.10, blue: 0.44)
    ]
    
    private let points: [SIMD2<Float>] = [
        SIMD2<Float>(0.0, 0.0), SIMD2<Float>(0.5, 0.0), SIMD2<Float>(1.0, 0.0),
        SIMD2<Float>(0.0, 0.5), SIMD2<Float>(0.5, 0.5), SIMD2<Float>(1.0, 0.5),
        SIMD2<Float>(0.0, 1.0), SIMD2<Float>(0.5, 1.0), SIMD2<Float>(1.0, 1.0)
    ]
    
    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0/30.0)) { timeline in
            MeshGradient(
                width: 3,
                height: 3,
                points: points,
                colors: animatedColors(for: timeline.date),
                background: .black,
                smoothsColors: true
            )
        }
    }
    
    private func animatedColors(for date: Date) -> [Color] {
        let phase = CGFloat(date.timeIntervalSince1970)
        
        return colors.enumerated().map { index, color in
            let hueShift = cos(phase + Double(index) * 0.3) * 0.1
            return shiftHue(of: color, by: hueShift)
        }
    }
    
    private func shiftHue(of color: Color, by amount: Double) -> Color {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        
        UIColor(color).getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        
        hue += CGFloat(amount)
        hue = hue.truncatingRemainder(dividingBy: 1.0)
        
        if hue < 0 { hue += 1 }
        
        return Color(hue: Double(hue), saturation: Double(saturation), brightness: Double(brightness), opacity: Double(alpha))
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        EventDetailsView(
            jobID: "XR9Q2L",
            imageURL: URL(string: "https://paiza-webapp.s3.ap-northeast-1.amazonaws.com/recruiter/5427/photo_top/large-3e64bc594b80bd45570a4fb1667eef8f.jpg"),
            eikenRequired: "2級",
            toeicRequired: "700",
            companyLogo: "Solvvy",
            title: "コンサル志望学生向け: 【金融×IT】を上場企業で学べる3DAYインターン",
            businessName: "Solvvy株式会社",
            stationName: "舞浜駅",
            jobDuration: "3ヶ月以上から",
            roleKind: "アルバイト・パート",
            payHourly: "¥1,520",
            payAdded: "220"
        )
        .navigationBarTitleDisplayMode(.inline)
    }
}

