import SwiftUI

struct ColorInspectionSheet: View {
    let inspection: ColorInspection
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("선택 색상")
                            .font(.caption.monospaced().weight(.semibold))
                            .foregroundStyle(UnseenTheme.accent)

                        HStack(spacing: 12) {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(Color(hex: inspection.pickedHex) ?? .clear)
                                .frame(width: 54, height: 54)
                                .overlay {
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .stroke(UnseenTheme.border, lineWidth: 1)
                                }
                                .accessibilityHidden(true)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(inspection.pickedHex)
                                    .font(.title3.monospaced().weight(.semibold))
                                Text("RGB \(inspection.pickedRGB)")
                                    .font(.caption.monospaced())
                                    .foregroundStyle(UnseenTheme.dim)
                            }
                        }
                    }

                    Divider().overlay(UnseenTheme.border)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("모드별 변환")
                            .font(.caption.monospaced().weight(.semibold))
                            .foregroundStyle(UnseenTheme.accent)

                        ForEach(inspection.modeSamples, id: \.0) { mode, hex in
                            HStack {
                                Text(mode.rawValue)
                                    .font(.subheadline.weight(.medium))
                                Spacer()
                                Text(hex)
                                    .font(.caption.monospaced())
                                    .foregroundStyle(UnseenTheme.dim)
                            }
                            .padding(.vertical, 4)
                            .accessibilityElement(children: .combine)
                            .accessibilityLabel("\(mode.rawValue) 모드 색상")
                            .accessibilityValue(hex)
                        }
                    }

                    Divider().overlay(UnseenTheme.border)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("권장 대체 색상")
                            .font(.caption.monospaced().weight(.semibold))
                            .foregroundStyle(UnseenTheme.accent)

                        ForEach(inspection.suggestions) { suggestion in
                            HStack(spacing: 10) {
                                RoundedRectangle(cornerRadius: 6, style: .continuous)
                                    .fill(Color(hex: suggestion.hex) ?? .clear)
                                    .frame(width: 26, height: 26)
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                                            .stroke(UnseenTheme.border, lineWidth: 1)
                                    }
                                    .accessibilityHidden(true)

                                Text(suggestion.role)
                                    .font(.subheadline.weight(.medium))

                                Spacer()

                                Text(suggestion.hex)
                                    .font(.caption.monospaced())
                                    .foregroundStyle(UnseenTheme.dim)
                            }
                            .padding(.vertical, 2)
                            .accessibilityElement(children: .combine)
                            .accessibilityLabel("\(suggestion.role) 추천 색상")
                            .accessibilityValue(suggestion.hex)
                        }
                    }
                }
                .padding(20)
            }
            .background(UnseenTheme.bg.ignoresSafeArea())
            .navigationTitle("색상 상세 분석")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("닫기") { dismiss() }
                        .accessibilityLabel("색상 상세 분석 닫기")
                }
            }
        }
    }
}

private extension Color {
    init?(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        guard hex.count == 6, let int = Int(hex, radix: 16) else { return nil }

        let r = Double((int >> 16) & 0xFF) / 255.0
        let g = Double((int >> 8) & 0xFF) / 255.0
        let b = Double(int & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}
