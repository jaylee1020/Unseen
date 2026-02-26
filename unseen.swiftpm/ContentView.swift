import SwiftUI

// MARK: - Theme
private enum UnseenTheme {
    static let bg = Color(red: 250/255, green: 250/255, blue: 248/255)
    static let surface = Color.white
    static let surface2 = Color(red: 244/255, green: 244/255, blue: 240/255)
    static let border = Color(red: 226/255, green: 226/255, blue: 220/255)
    static let text = Color(red: 24/255, green: 24/255, blue: 15/255)
    static let dim = Color(red: 113/255, green: 113/255, blue: 106/255)
    static let accent = Color(red: 196/255, green: 65/255, blue: 0)
    static let accentBackground = Color(red: 1.0, green: 244/255, blue: 237/255)
    static let green = Color(red: 26/255, green: 122/255, blue: 76/255)
    static let greenBackground = Color(red: 238/255, green: 248/255, blue: 241/255)
    static let red = Color(red: 196/255, green: 51/255, blue: 51/255)
    static let redBackground = Color(red: 253/255, green: 240/255, blue: 240/255)
    static let blue = Color(red: 29/255, green: 95/255, blue: 160/255)
    static let blueBackground = Color(red: 238/255, green: 244/255, blue: 251/255)
}

enum VisionMode: String, CaseIterable, Identifiable {
    case normal = "Normal"
    case deuteranopia = "Deuteranopia"
    case protanopia = "Protanopia"
    case tritanopia = "Tritanopia"

    var id: Self { self }
}

struct DemoIssue: Identifiable {
    let id = UUID()
    let title: String
    let message: String
    let fix: String
}

// MARK: - Root
struct ContentView: View {
    var body: some View {
        TabView {
            PitchView()
                .tabItem {
                    Label("Pitch", systemImage: "doc.text.image")
                }

            PrototypeView()
                .tabItem {
                    Label("Prototype", systemImage: "camera.viewfinder")
                }
        }
        .tint(UnseenTheme.accent)
        .background(UnseenTheme.bg.ignoresSafeArea())
    }
}

// MARK: - Pitch Screen
private struct PitchView: View {
    private let demoSteps: [(time: String, title: String, detail: String)] = [
        ("0:00–0:10", "한 줄, 바로 카메라", "전 세계 남성의 8%는 당신이 보는 색을 다르게 봅니다. 별도 온보딩 없이 바로 카메라 모드 진입."),
        ("0:10–0:50", "시뮬레이션 충격", "Deuteranopia 토글로 빨강-초록이 동일하게 보이는 순간을 즉시 체험."),
        ("0:50–1:50", "자동 감지", "구분 어려운 인접 색 영역을 탐지해서 ⚠️ 오버레이로 즉시 표시."),
        ("1:50–2:30", "대체 색상 제안", "탭 한 번으로 대체 색상 조합과 접근성 근거를 제시."),
        ("2:30–3:00", "교육 카드", "디자이너/교사를 위한 접근성 규칙 카드로 즉시 실천 유도.")
    ]

    private let techSpecs: [(key: String, value: String)] = [
        ("Platform", "iPad App Playground (.swiftpm)"),
        ("Target", "iPadOS 18+"),
        ("Core", "SwiftUI + AVFoundation + Metal"),
        ("Color Science", "Brettel/Viénot 기반 색변환"),
        ("Detection", "색차 기반 위험 조합 탐지"),
        ("Alternative", "WCAG 대비 기반 대체 색 제안"),
        ("Network", "100% Offline")
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 30) {
                hero

                PitchSection(label: "Origin Story", title: "이 앱은 내 실수에서 시작됐다") {
                    StoryCard {
                        Text("저는 교육 콘텐츠를 만드는 디자이너로 일하며 빨강=오답, 초록=정답을 당연하게 사용했습니다. 하지만 남성의 약 8%가 적-녹 색각이상이라는 사실을 알고, 제 작업물이 일부 학생에게는 정보를 가리지 못한다는 걸 깨달았습니다.")
                        Text("Unseen은 그 반성에서 출발한 도구입니다. **문제를 보여주는 것**에서 끝나지 않고, **즉시 고칠 수 있도록 안내**합니다.")
                    }
                    .padding(.bottom, 2)

                    Text("핵심 메시지: *기술은 모든 사람이 정보를 동등하게 읽을 수 있게 만들기 위해 존재한다.*")
                        .foregroundStyle(UnseenTheme.dim)
                        .font(.system(size: 14))
                }

                PitchSection(label: "The Problem", title: "빨강-초록 구분이 사라지는 순간") {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("정상 색각")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(UnseenTheme.text)
                        SwatchRow(colors: [
                            (Color(red: 231/255, green: 76/255, blue: 60/255), "오답"),
                            (Color(red: 46/255, green: 204/255, blue: 113/255), "정답"),
                            (Color(red: 52/255, green: 152/255, blue: 219/255), "참고"),
                            (Color(red: 243/255, green: 156/255, blue: 18/255), "강조")
                        ])

                        Text("Deuteranopia 시야")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(UnseenTheme.text)
                        SwatchRow(colors: [
                            (Color(red: 160/255, green: 138/255, blue: 64/255), "???"),
                            (Color(red: 160/255, green: 138/255, blue: 64/255), "???"),
                            (Color(red: 49/255, green: 100/255, blue: 160/255), "파랑"),
                            (Color(red: 212/255, green: 168/255, blue: 32/255), "노랑")
                        ])
                    }

                    TwoColumnCards(items: [
                        .init(title: "문제의 규모", text: "전 세계 약 3억 명. 한국 남성 5.9%. 30명 반에서 1~2명이 겪는 문제."),
                        .init(title: "기존 솔루션 한계", text: "정적 필터 중심. 실물 인쇄물·교실 현장·간판 등에서는 즉시 검수가 어려움.")
                    ])
                }

                PitchSection(label: "One Key Feature", title: "카메라를 들면, 보이지 않던 것이 보인다") {
                    KeyCallout(text: "카메라 하나로 실시간 시뮬레이션 + 위험 조합 탐지 + 대체 색상 제안을 연결한 접근성 진단 도구")

                    BulletBlock(title: "① 실시간 색각이상 시뮬레이션", description: "Metal shader로 매 프레임 RGB→LMS→시뮬레이션→RGB 변환")
                    BulletBlock(title: "② 위험 색 조합 자동 감지", description: "구분 어려운 인접 색 영역에 ⚠️ 오버레이를 즉시 표시")
                    BulletBlock(title: "③ 탭 기반 대체 색상 제안", description: "의미(정답/오답)를 유지하면서 가시성 높은 색 조합 추천")
                }

                PitchSection(label: "Why App", title: "이게 왜 앱이어야 하는가") {
                    TwoColumnCards(items: [
                        .init(title: "실물 검사", text: "인쇄물·교실 보드·현장 안내판을 바로 점검"),
                        .init(title: "즉시 피드백", text: "촬영/업로드 없이 비추는 즉시 문제 확인"),
                        .init(title: "반복 사용", text: "디자이너·교사가 제작 단계마다 검수 루틴화"),
                        .init(title: "네이티브 성능", text: "실시간 GPU 처리로 웹 대비 낮은 지연")
                    ])
                }

                PitchSection(label: "3-Min Demo", title: "심사위원이 3분 안에 체감하는 흐름") {
                    VStack(spacing: 10) {
                        ForEach(demoSteps, id: \.time) { step in
                            FlowStep(time: step.time, title: step.title, detail: step.detail)
                        }
                    }
                }

                PitchSection(label: "Differentiation", title: "시뮬레이터가 아니라 진단 도구") {
                    ComparisonView(
                        leftTitle: "기존 앱",
                        leftPoints: [
                            "정적 이미지 기반",
                            "문제 설명 중심",
                            "해결 제안 부족"
                        ],
                        rightTitle: "Unseen",
                        rightPoints: [
                            "실시간 카메라 기반",
                            "문제 자동 감지",
                            "대체 색상 제안"
                        ]
                    )
                }

                PitchSection(label: "Judging Fit", title: "심사 기준 매핑") {
                    TwoColumnCards(items: [
                        .init(title: "Innovation", text: "실시간 변환 + 감지 + 처방 결합"),
                        .init(title: "Creativity", text: "카메라 단일 인터페이스로 전체 워크플로우 통합"),
                        .init(title: "Social Impact", text: "접근성 사각지대를 줄이는 반복 가능한 실천 도구"),
                        .init(title: "Inclusivity", text: "당사자와 제작자 모두에게 동시에 가치 제공")
                    ])
                }

                PitchSection(label: "Tech Spec", title: "기술 명세") {
                    VStack(spacing: 0) {
                        ForEach(Array(techSpecs.enumerated()), id: \.offset) { _, row in
                            HStack(alignment: .top, spacing: 14) {
                                Text(row.key)
                                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
                                    .foregroundStyle(UnseenTheme.dim)
                                    .frame(width: 115, alignment: .leading)
                                Text(row.value)
                                    .font(.system(size: 13))
                                    .foregroundStyle(UnseenTheme.text)
                                Spacer(minLength: 0)
                            }
                            .padding(.vertical, 10)

                            Divider()
                                .overlay(UnseenTheme.border)
                        }
                    }
                    .padding(14)
                    .background(UnseenTheme.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(UnseenTheme.border, lineWidth: 1)
                    }
                }

                PitchSection(label: "Roadmap", title: "2일 우선순위") {
                    VStack(spacing: 12) {
                        FlowStep(time: "D1", title: "카메라 + Shader + 토글", detail: "실시간 시뮬레이션 파이프라인 완성")
                        FlowStep(time: "D2", title: "감지 + 대체 색 + 제출 준비", detail: "오버레이 감지, 제안 UI, 접근성 체크리스트 마감")
                    }
                }

                FinalCallout()
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)
            .padding(.bottom, 100)
        }
        .background(UnseenTheme.bg.ignoresSafeArea())
    }

    private var hero: some View {
        VStack(spacing: 12) {
            Text("SSC 2026 — Final Concept")
                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                .tracking(2.3)
                .textCase(.uppercase)
                .foregroundStyle(UnseenTheme.accent)
                .padding(.vertical, 5)
                .padding(.horizontal, 14)
                .background(UnseenTheme.accentBackground)
                .clipShape(Capsule())

            Text("Unseen")
                .font(.system(size: 62, weight: .regular, design: .serif))
                .minimumScaleFactor(0.7)
                .foregroundStyle(UnseenTheme.text)

            Text("\"내가 만든 디자인이 누군가에게는 보이지 않았다.\"")
                .font(.system(size: 19, weight: .regular, design: .serif))
                .italic()
                .foregroundStyle(UnseenTheme.accent)

            Text("교육 자료·인쇄물·화면을 iPad 카메라로 비추면, 색각이상자의 시야로 실시간 변환하고 문제가 되는 색 조합을 자동으로 감지하는 접근성 진단 도구")
                .font(.system(size: 15))
                .foregroundStyle(UnseenTheme.dim)
                .multilineTextAlignment(.center)
                .padding(.top, 4)
                .frame(maxWidth: 520)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 34)
        .padding(.horizontal, 16)
        .background(UnseenTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(UnseenTheme.border, lineWidth: 1)
        }
    }
}

// MARK: - Prototype Screen
private struct PrototypeView: View {
    @State private var mode: VisionMode = .deuteranopia
    @State private var showWarnings = true
    @State private var showSuggestions = true

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Live Prototype")
                    .font(.system(size: 30, weight: .regular, design: .serif))
                    .foregroundStyle(UnseenTheme.text)

                Text("카메라 + 감지 + 대체 제안 흐름을 심사 데모용으로 빠르게 확인하는 프로토타입 화면")
                    .font(.system(size: 14))
                    .foregroundStyle(UnseenTheme.dim)

                VStack(alignment: .leading, spacing: 10) {
                    Text("시야 모드")
                        .font(.system(size: 12, weight: .semibold, design: .monospaced))
                        .foregroundStyle(UnseenTheme.accent)

                    Picker("시야 모드", selection: $mode) {
                        ForEach(VisionMode.allCases) { item in
                            Text(item.rawValue).tag(item)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Toggle("위험 영역 경고 표시", isOn: $showWarnings)
                    .tint(UnseenTheme.accent)
                Toggle("대체 색상 제안 표시", isOn: $showSuggestions)
                    .tint(UnseenTheme.accent)

                CameraMockCard(mode: mode, showWarnings: showWarnings)

                if showSuggestions {
                    SuggestionCard(issues: issueList(for: mode))
                }

                ChecklistCard()
            }
            .padding(20)
            .padding(.bottom, 80)
        }
        .background(UnseenTheme.bg.ignoresSafeArea())
    }

    private func issueList(for mode: VisionMode) -> [DemoIssue] {
        switch mode {
        case .normal:
            return [
                DemoIssue(title: "현재 모드", message: "정상 색각 기준에서는 치명적 충돌이 적습니다.", fix: "대비 비율(WCAG)만 추가 검증")
            ]
        case .deuteranopia, .protanopia:
            return [
                DemoIssue(title: "빨강/초록 충돌", message: "오답/정답 색이 유사한 갈색 계열로 보입니다.", fix: "오답=주황(#D26A00), 정답=파랑(#2F6EE2) 권장"),
                DemoIssue(title: "상태 뱃지 구분 약함", message: "색만으로 상태를 전달하면 오해 가능성이 높습니다.", fix: "아이콘+텍스트 레이블 동시 사용")
            ]
        case .tritanopia:
            return [
                DemoIssue(title: "파랑/노랑 가독성 저하", message: "보조 정보와 강조 정보가 비슷하게 보일 수 있습니다.", fix: "노랑 계열 채도↓, 대비↑ 조정")
            ]
        }
    }
}

// MARK: - Reusable Views
private struct PitchSection<Content: View>: View {
    let label: String
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(label)
                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                .tracking(2.2)
                .foregroundStyle(UnseenTheme.accent)
                .textCase(.uppercase)

            Text(title)
                .font(.system(size: 28, weight: .regular, design: .serif))
                .foregroundStyle(UnseenTheme.text)

            content
        }
    }
}

private struct StoryCard<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Jay의 이야기")
                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                .tracking(1.3)
                .foregroundStyle(UnseenTheme.accent)
                .textCase(.uppercase)

            content
                .font(.system(size: 14))
                .foregroundStyle(UnseenTheme.text)
                .lineSpacing(3)
        }
        .padding(20)
        .background(UnseenTheme.surface2)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(UnseenTheme.accent)
                .frame(width: 3)
                .clipShape(RoundedRectangle(cornerRadius: 3, style: .continuous))
        }
    }
}

private struct SwatchRow: View {
    let colors: [(Color, String)]

    var body: some View {
        HStack(spacing: 2) {
            ForEach(Array(colors.enumerated()), id: \.offset) { _, item in
                VStack {
                    Text(item.1)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white)
                }
                .frame(maxWidth: .infinity, minHeight: 56)
                .background(item.0)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(UnseenTheme.border, lineWidth: 1)
        }
    }
}

private struct TwoColumnCards: View {
    struct Item {
        let title: String
        let text: String
    }

    let items: [Item]
    private let columns = [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                VStack(alignment: .leading, spacing: 6) {
                    Text(item.title)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(UnseenTheme.text)
                    Text(item.text)
                        .font(.system(size: 13))
                        .foregroundStyle(UnseenTheme.dim)
                        .lineSpacing(2)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(14)
                .background(UnseenTheme.surface)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(UnseenTheme.border, lineWidth: 1)
                }
            }
        }
    }
}

private struct KeyCallout: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 15, weight: .medium))
            .foregroundStyle(UnseenTheme.text)
            .lineSpacing(3)
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(UnseenTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(alignment: .topLeading) {
                Text("★ 핵심")
                    .font(.system(size: 10, weight: .semibold, design: .monospaced))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(UnseenTheme.text)
                    .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                    .offset(x: 18, y: -11)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(UnseenTheme.text, lineWidth: 1.5)
            }
            .padding(.top, 10)
    }
}

private struct BulletBlock: View {
    let title: String
    let description: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(UnseenTheme.text)
            Text(description)
                .font(.system(size: 14))
                .foregroundStyle(UnseenTheme.dim)
        }
        .padding(.vertical, 4)
    }
}

private struct FlowStep: View {
    let time: String
    let title: String
    let detail: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(time)
                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                .foregroundStyle(UnseenTheme.accent)
                .frame(width: 70, alignment: .leading)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(UnseenTheme.text)
                Text(detail)
                    .font(.system(size: 13))
                    .foregroundStyle(UnseenTheme.dim)
            }
            Spacer(minLength: 0)
        }
        .padding(14)
        .background(UnseenTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(UnseenTheme.border, lineWidth: 1)
        }
    }
}

private struct ComparisonView: View {
    let leftTitle: String
    let leftPoints: [String]
    let rightTitle: String
    let rightPoints: [String]

    var body: some View {
        HStack(spacing: 10) {
            compareColumn(title: leftTitle, points: leftPoints, color: UnseenTheme.red, bg: UnseenTheme.redBackground)
            compareColumn(title: rightTitle, points: rightPoints, color: UnseenTheme.green, bg: UnseenTheme.greenBackground)
        }
    }

    private func compareColumn(title: String, points: [String], color: Color, bg: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(color)
            ForEach(points, id: \.self) { point in
                Text("• \(point)")
                    .font(.system(size: 13))
                    .foregroundStyle(UnseenTheme.text)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(bg)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

private struct FinalCallout: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("결론")
                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                .foregroundStyle(UnseenTheme.green)
                .textCase(.uppercase)
                .tracking(1.5)

            Text("Unseen은 실사용 맥락(교육 디자인)에서 시작해 실제 문제(색각 접근성)를 해결하는 도구로 연결됩니다. 시뮬레이션을 넘어 진단과 처방까지 제공하는 점이 SSC 우승 포인트입니다.")
                .font(.system(size: 14))
                .foregroundStyle(UnseenTheme.text)
                .lineSpacing(3)
        }
        .padding(18)
        .background(UnseenTheme.greenBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(UnseenTheme.green)
                .frame(width: 3)
                .clipShape(RoundedRectangle(cornerRadius: 3, style: .continuous))
        }
    }
}

private struct CameraMockCard: View {
    let mode: VisionMode
    let showWarnings: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Live Camera Mock")
                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                .foregroundStyle(UnseenTheme.accent)

            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color.black.opacity(0.82), Color.black.opacity(0.64)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(height: 220)

                VStack(spacing: 14) {
                    Text("\(mode.rawValue) Preview")
                        .font(.system(size: 12, weight: .semibold, design: .monospaced))
                        .foregroundStyle(.white.opacity(0.86))

                    SwatchRow(colors: swatches(for: mode))
                        .frame(height: 58)
                        .padding(.horizontal, 16)

                    if showWarnings {
                        HStack(spacing: 8) {
                            warningBadge("오답/정답 구분 위험")
                            warningBadge("그래프 범례 충돌")
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(UnseenTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(UnseenTheme.border, lineWidth: 1)
        }
    }

    private func warningBadge(_ text: String) -> some View {
        Text("⚠️ \(text)")
            .font(.system(size: 11, weight: .semibold, design: .monospaced))
            .foregroundStyle(Color(red: 1.0, green: 0.88, blue: 0.72))
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(Color(red: 0.42, green: 0.18, blue: 0.03).opacity(0.8))
            .clipShape(Capsule())
    }

    private func swatches(for mode: VisionMode) -> [(Color, String)] {
        switch mode {
        case .normal:
            return [
                (Color(red: 231/255, green: 76/255, blue: 60/255), "오답"),
                (Color(red: 46/255, green: 204/255, blue: 113/255), "정답"),
                (Color(red: 52/255, green: 152/255, blue: 219/255), "참고"),
                (Color(red: 243/255, green: 156/255, blue: 18/255), "강조")
            ]
        case .deuteranopia:
            return [
                (Color(red: 160/255, green: 138/255, blue: 64/255), "오답"),
                (Color(red: 160/255, green: 138/255, blue: 64/255), "정답"),
                (Color(red: 49/255, green: 100/255, blue: 160/255), "참고"),
                (Color(red: 212/255, green: 168/255, blue: 32/255), "강조")
            ]
        case .protanopia:
            return [
                (Color(red: 145/255, green: 130/255, blue: 80/255), "오답"),
                (Color(red: 144/255, green: 129/255, blue: 81/255), "정답"),
                (Color(red: 52/255, green: 104/255, blue: 153/255), "참고"),
                (Color(red: 209/255, green: 170/255, blue: 45/255), "강조")
            ]
        case .tritanopia:
            return [
                (Color(red: 198/255, green: 89/255, blue: 77/255), "오답"),
                (Color(red: 72/255, green: 162/255, blue: 130/255), "정답"),
                (Color(red: 110/255, green: 123/255, blue: 145/255), "참고"),
                (Color(red: 184/255, green: 170/255, blue: 108/255), "강조")
            ]
        }
    }
}

private struct SuggestionCard: View {
    let issues: [DemoIssue]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("진단 결과")
                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                .foregroundStyle(UnseenTheme.accent)

            ForEach(issues) { issue in
                VStack(alignment: .leading, spacing: 6) {
                    Text(issue.title)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(UnseenTheme.text)
                    Text(issue.message)
                        .font(.system(size: 13))
                        .foregroundStyle(UnseenTheme.dim)
                    Text("대안: \(issue.fix)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(UnseenTheme.blue)
                }
                .padding(12)
                .background(UnseenTheme.blueBackground)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
        }
        .padding(16)
        .background(UnseenTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(UnseenTheme.border, lineWidth: 1)
        }
    }
}

private struct ChecklistCard: View {
    private let checklist = [
        "카메라 접근 권한 실패 시 샘플 이미지 폴백",
        "접근성: VoiceOver 라벨 + Dynamic Type 대응",
        "경고 감지는 1초 내 반응하도록 성능 확인",
        "대체 색상 제안에 WCAG 대비 근거 표기"
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("D-2 체크리스트")
                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                .foregroundStyle(UnseenTheme.accent)

            ForEach(checklist, id: \.self) { item in
                Text("• \(item)")
                    .font(.system(size: 13))
                    .foregroundStyle(UnseenTheme.text)
            }
        }
        .padding(16)
        .background(UnseenTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(UnseenTheme.border, lineWidth: 1)
        }
    }
}

#Preview {
    ContentView()
}
