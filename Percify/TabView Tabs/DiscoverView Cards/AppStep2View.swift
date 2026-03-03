//
//  AppStep2View.swift
//  Bybeit
//
//  UI-only version (no backend / no external dependencies on job data)
//

import SwiftUI
import ConfettiSwiftUI

struct AppStep2View: View {
    // Keep the same public API, but the values are only used for UI display.
    let jobID: String
    let category: String

    // Optional binding to control the top-level sheet if provided by the presenter
    @Binding var isPresented: Bool?
    @Environment(\.dismiss) private var dismiss

    @State private var confettiCounter = 0
    @State private var showAppliedSheet = false

    var body: some View {
        NavigationStack {
            VStack(alignment: .center, spacing: 30) {
                Spacer()
                Spacer()

                VStack(alignment: .center, spacing: 18) {
                    Image(systemName: "checkmark.circle")
                        .font(.system(size: 63))
                        .fontWeight(.regular)
                        .foregroundColor(.green)
                        .symbolEffect(.bounce, options: .nonRepeating)

                    Text("応募が完了しました")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)

                    Text("あなたのデータ、応募を確認しています。次の\nステップは、まもなく通知でご案内します。")
                        .multilineTextAlignment(.center)
                        .font(.body)
                        .padding(.horizontal)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: true, vertical: true)
                        .lineLimit(2)
                }
                .padding(.top, 120)

                Spacer()

                Button {
                    showAppliedSheet = true
                } label: {
                    Text("応募の進捗を確認")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .font(.title3)
                }
                .foregroundColor(.white)
                .fontWeight(.semibold)
                .buttonStyle(.glassProminent)
                .frame(width: UIScreen.main.bounds.width * 0.85)
                .padding(.bottom, 180)

                Spacer()
            }
            .ignoresSafeArea()
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button {
                        if var presented = isPresented {
                            presented = false
                            isPresented = presented
                        } else {
                            dismiss()
                        }
                    } label: {
                        Label { Text("dismiss") } icon: { Image(systemName: "xmark") }
                    }
                }
            }
            .onAppear {
                // Purely visual UI effect: confetti.
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    confettiCounter += 1
                }
            }
        }
        .confettiCannon(
            trigger: $confettiCounter,
            num: 130,
            confettis: [
                .shape(.circle),
                .shape(.triangle),
                .shape(.square),
                .shape(.slimRectangle)
            ],
            confettiSize: 10.5,
            openingAngle: Angle(degrees: 0),
            closingAngle: Angle(degrees: 360),
            radius: 270
        )
        .presentationBackground(.clear)
        .sheet(isPresented: $showAppliedSheet) {
            AppliedProgressPreviewView(jobID: jobID, category: category)
                .presentationDetents([.large])
        }
    }
}

// MARK: - UI-only placeholder sheet (replaces AppliedView)

private struct AppliedProgressPreviewView: View {
    let jobID: String
    let category: String

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("応募状況")
                                .font(.headline)
                            Text("現在のステータス（プレビュー）")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Image(systemName: "clock.badge.checkmark")
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 6)
                }

                Section("ステップ") {
                    StatusRow(title: "応募受付", subtitle: "完了", state: .done)
                    StatusRow(title: "内容確認", subtitle: "進行中（プレビュー）", state: .inProgress)
                    StatusRow(title: "次の案内", subtitle: "未開始", state: .todo)
                }

                Section("参照（UIのみ）") {
                    LabeledContent("jobID", value: jobID)
                    LabeledContent("category", value: category)
                }
            }
            .navigationTitle("応募の進捗")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
            }
        }
    }

    private struct StatusRow: View {
        enum State { case done, inProgress, todo }

        let title: String
        let subtitle: String
        let state: State

        var body: some View {
            HStack(spacing: 12) {
                Image(systemName: iconName)
                    .foregroundColor(iconColor)
                    .font(.title3)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.body)
                    Text(subtitle)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }

                Spacer()
            }
            .padding(.vertical, 4)
        }

        private var iconName: String {
            switch state {
            case .done: return "checkmark.circle.fill"
            case .inProgress: return "hourglass.circle.fill"
            case .todo: return "circle"
            }
        }

        private var iconColor: Color {
            switch state {
            case .done: return .green
            case .inProgress: return .orange
            case .todo: return .secondary
            }
        }
    }
}

#Preview {
    AppStep2View(jobID: "XR9Q2L", category: "jobs", isPresented: .constant(nil))
}
