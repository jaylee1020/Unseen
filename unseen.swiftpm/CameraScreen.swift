import SwiftUI
import UIKit

struct CameraScreen: View {
    @StateObject private var vm = CameraAnalyzerViewModel()
    @State private var showEducationSheet = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                hero
                cameraSection
                controlsSection
                findingsSection
                whyAppSection
                demoFlowSection
                educationCardsSection
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)
            .padding(.bottom, 80)
        }
        .background(UnseenTheme.bg.ignoresSafeArea())
        .task { vm.start() }
        .onDisappear { vm.stop() }
        .sheet(item: $vm.inspection) { inspection in
            ColorInspectionSheet(inspection: inspection)
        }
        .sheet(isPresented: $showEducationSheet) {
            EducationCardsSheet()
        }
    }

    private var hero: some View {
        VStack(spacing: 10) {
            Text("SSC 2026 — Refined Idea")
                .font(.caption2.monospaced().weight(.semibold))
                .tracking(2.2)
                .textCase(.uppercase)
                .foregroundStyle(UnseenTheme.accent)
                .padding(.vertical, 5)
                .padding(.horizontal, 14)
                .background(UnseenTheme.accentBackground)
                .clipShape(Capsule())

            Text("Unseen")
                .font(.system(.largeTitle, design: .serif, weight: .regular))
                .foregroundStyle(UnseenTheme.text)
                .minimumScaleFactor(0.7)

            Text("See what 300 million people can't.")
                .font(.system(.title3, design: .serif, weight: .regular))
                .italic()
                .foregroundStyle(UnseenTheme.accent)
                .multilineTextAlignment(.center)

            Text("카메라가 없으면 존재할 수 없는 앱. 실물(포스터·간판·교재·UI)을 비추면 색각이상 시야 + WCAG 대비 진단을 실시간으로 보여줍니다.")
                .font(.callout)
                .foregroundStyle(UnseenTheme.dim)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 520)
        }
        .frame(maxWidth: .infinity)
        .padding(22)
        .background(UnseenTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(UnseenTheme.border, lineWidth: 1)
        }
    }

    private var cameraSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("카메라 뷰파인더")
                    .font(.caption.monospaced().weight(.semibold))
                    .foregroundStyle(UnseenTheme.accent)
                Spacer()
                if vm.useSampleFallback {
                    Text("DEMO SAMPLE")
                        .font(.caption2.monospaced().weight(.semibold))
                        .foregroundStyle(UnseenTheme.blue)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(UnseenTheme.blueBackground)
                        .clipShape(Capsule())
                }
            }

            GeometryReader { geo in
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.black.opacity(0.85))

                    if let frame = vm.frame {
                        Image(decorative: frame, scale: 1.0, orientation: .up)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .accessibilityHidden(true)
                    } else {
                        Text("카메라 프레임 대기 중...")
                            .font(.footnote)
                            .foregroundStyle(.white.opacity(0.75))
                    }

                    ForEach(vm.findings) { finding in
                        let rect = vm.overlayRect(for: finding.normalizedBox, in: geo.size)
                        if rect.width > AnalysisConstants.minOverlayEdge, rect.height > AnalysisConstants.minOverlayEdge {
                            ZStack(alignment: .topLeading) {
                                RoundedRectangle(cornerRadius: 6, style: .continuous)
                                    .stroke(finding.pass ? UnseenTheme.green : UnseenTheme.red, lineWidth: 1.6)

                                Text("\(finding.pass ? "PASS" : "FAIL") \(String(format: "%.2f", finding.ratio))")
                                    .font(.caption2.monospaced().weight(.bold))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 3)
                                    .background(finding.pass ? UnseenTheme.green : UnseenTheme.red)
                                    .clipShape(Capsule())
                                    .offset(x: 4, y: 4)
                            }
                            .frame(width: rect.width, height: rect.height)
                            .position(x: rect.midX, y: rect.midY)
                            .accessibilityElement(children: .ignore)
                            .accessibilityLabel("\(finding.pass ? "통과" : "실패") 텍스트: \(finding.text)")
                            .accessibilityValue("대비 \(String(format: "%.2f", finding.ratio))")
                        }
                    }
                }
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onEnded { value in
                            vm.inspect(at: value.location, in: geo.size)
                        }
                )
                .accessibilityElement(children: .combine)
                .accessibilityLabel("실시간 카메라 진단 화면")
                .accessibilityHint("화면을 탭하면 선택 색상 상세 분석이 열립니다.")
            }
            .frame(height: 300)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(UnseenTheme.border, lineWidth: 1)
            }

            Text("화면을 탭하면 색상 상세/대체 색상이 뜹니다.")
                .font(.footnote)
                .foregroundStyle(UnseenTheme.dim)

            HStack(spacing: 8) {
                Capsule()
                    .fill(UnseenTheme.border)
                    .frame(width: 34, height: 4)
                Text("위로 스와이프하면 교육 카드")
                    .font(.caption)
                    .foregroundStyle(UnseenTheme.dim)
                Spacer()
                Button("열기") {
                    showEducationSheet = true
                }
                .font(.caption.monospaced().weight(.semibold))
                .foregroundStyle(UnseenTheme.accent)
                .accessibilityLabel("교육 카드 열기")
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 16)
                    .onEnded { value in
                        if value.translation.height < -20 {
                            showEducationSheet = true
                        }
                    }
            )
        }
        .padding(16)
        .background(UnseenTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(UnseenTheme.border, lineWidth: 1)
        }
    }

    private var controlsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("실시간 진단 설정")
                .font(.caption.monospaced().weight(.semibold))
                .foregroundStyle(UnseenTheme.accent)

            Picker("색각 모드", selection: $vm.mode) {
                ForEach(VisionMode.allCases) { mode in
                    Text(mode.shortLabel).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .accessibilityLabel("색각 모드 선택")
            .accessibilityHint("정상, 적-녹, 적색약, 청색약 모드를 전환합니다.")

            Toggle("텍스트 인식 + WCAG 대비 분석", isOn: $vm.analyzeText)
                .tint(UnseenTheme.accent)
                .accessibilityLabel("텍스트 인식 및 대비 분석")

            Button {
                vm.isFrozen.toggle()
                if vm.isFrozen {
                    vm.statusText = "프레임 고정됨"
                } else {
                    vm.statusText = vm.useSampleFallback ? "샘플 모드" : "실시간 카메라 분석 중"
                }
            } label: {
                Label(vm.isFrozen ? "분석 재개" : "프레임 고정", systemImage: vm.isFrozen ? "play.fill" : "pause.fill")
                    .font(.subheadline.weight(.semibold))
            }
            .buttonStyle(.bordered)
            .tint(UnseenTheme.accent)
            .accessibilityHint("고정된 프레임으로 진단을 확인할 수 있습니다.")

            HStack(alignment: .firstTextBaseline, spacing: 10) {
                Text(vm.statusText)
                    .font(.footnote)
                    .foregroundStyle(UnseenTheme.dim)
                    .accessibilityLabel("상태")
                    .accessibilityValue(vm.statusText)

                Spacer()

                Button("샘플 모드") {
                    vm.activateSampleFallback(reason: "샘플 모드 수동 전환")
                }
                .font(.caption.monospaced().weight(.semibold))
                .foregroundStyle(UnseenTheme.blue)
                .accessibilityHint("카메라 없이 데모 화면으로 전환합니다.")
            }

            if vm.permissionDenied {
                Button("설정에서 카메라 권한 열기") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                .font(.subheadline.weight(.semibold))
                .padding(.top, 2)
                .accessibilityHint("iPad 설정 앱에서 카메라 권한을 변경합니다.")
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

    private var findingsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("진단 결과")
                .font(.caption.monospaced().weight(.semibold))
                .foregroundStyle(UnseenTheme.accent)

            if vm.findings.isEmpty {
                Text("텍스트를 인식하면 PASS/FAIL 결과가 여기에 표시됩니다.")
                    .font(.footnote)
                    .foregroundStyle(UnseenTheme.dim)
            } else {
                let failCount = vm.findings.filter { !$0.pass }.count
                let worstRatio = vm.findings.map(\.ratio).min() ?? 0

                HStack(spacing: 8) {
                    Text(failCount == 0 ? "ALL PASS" : "FAIL \(failCount)")
                        .font(.caption2.monospaced().weight(.bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(failCount == 0 ? UnseenTheme.green : UnseenTheme.red)
                        .clipShape(Capsule())
                        .accessibilityLabel(failCount == 0 ? "전체 통과" : "실패 \(failCount)개")

                    Text("worst \(String(format: "%.2f", worstRatio))")
                        .font(.caption.monospaced().weight(.semibold))
                        .foregroundStyle(UnseenTheme.dim)

                    Spacer()
                }
                .padding(.bottom, 2)

                ForEach(vm.findings.prefix(5)) { finding in
                    VStack(alignment: .leading, spacing: 5) {
                        Text(finding.text)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(UnseenTheme.text)
                            .lineLimit(2)
                            .minimumScaleFactor(0.8)

                        HStack(spacing: 8) {
                            Text(finding.pass ? "PASS" : "FAIL")
                                .font(.caption2.monospaced().weight(.bold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 7)
                                .padding(.vertical, 3)
                                .background(finding.pass ? UnseenTheme.green : UnseenTheme.red)
                                .clipShape(Capsule())

                            Text("contrast \(String(format: "%.2f", finding.ratio))")
                                .font(.caption.monospaced().weight(.semibold))
                                .foregroundStyle(UnseenTheme.dim)

                            Spacer()

                            Text("fg \(finding.foregroundHex)")
                                .font(.caption2.monospaced())
                                .foregroundStyle(UnseenTheme.dim)
                            Text("bg \(finding.backgroundHex)")
                                .font(.caption2.monospaced())
                                .foregroundStyle(UnseenTheme.dim)
                        }
                    }
                    .padding(10)
                    .background(UnseenTheme.surface2)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("텍스트 \(finding.text)")
                    .accessibilityValue("\(finding.pass ? "통과" : "실패"), 대비 \(String(format: "%.2f", finding.ratio))")
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

    private var whyAppSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Why this must be an app")
                .font(.caption.monospaced().weight(.semibold))
                .foregroundStyle(UnseenTheme.accent)

            Text("카메라가 없으면 존재할 수 없는 앱")
                .font(.system(.title2, design: .serif, weight: .regular))
                .foregroundStyle(UnseenTheme.text)

            Text("실물(포스터·간판·출력물)을 비추는 즉시 진단해야 하므로 웹 문서/포토샵 필터로 대체할 수 없습니다. 디자이너·교사가 반복적으로 사용하는 검수 도구라는 점이 핵심입니다.")
                .font(.callout)
                .foregroundStyle(UnseenTheme.dim)
                .lineSpacing(2)

            HStack(spacing: 10) {
                SmallCard(title: "실물 검사", body: "디지털 파일이 아닌 현실 세계 접근성 진단")
                SmallCard(title: "실시간", body: "비추는 즉시 결과")
                SmallCard(title: "반복 사용", body: "디자인 검수 루틴화")
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

    private var demoFlowSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("3-min demo flow")
                .font(.caption.monospaced().weight(.semibold))
                .foregroundStyle(UnseenTheme.accent)

            DemoStep(time: "0:00-0:15", title: "앱 오픈", detail: "한 줄 설명 후 즉시 카메라 진입")
            DemoStep(time: "0:15-0:50", title: "색각이상 시뮬레이션", detail: "토글 전환으로 빨강-초록 충돌 체감")
            DemoStep(time: "0:50-1:40", title: "PASS/FAIL 진단", detail: "텍스트 자동 인식 + WCAG 대비 계산")
            DemoStep(time: "1:40-2:20", title: "탭 상세 분석", detail: "HEX/RGB + 모드별 변환 + 대체 색 제안")
            DemoStep(time: "2:20-3:00", title: "반복 사용 가치", detail: "디자인 검수 도구로 실제 워크플로우 연결")
        }
        .padding(16)
        .background(UnseenTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(UnseenTheme.border, lineWidth: 1)
        }
    }

    private var educationCardsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("quick education cards")
                .font(.caption.monospaced().weight(.semibold))
                .foregroundStyle(UnseenTheme.accent)

            EducationCard(title: "색에만 의존하지 않기", body: "정답/오답, 상태값 전달 시 색 + 아이콘 + 텍스트를 함께 사용하세요.")
            EducationCard(title: "WCAG 대비 기준", body: "일반 텍스트는 4.5:1 이상, 큰 텍스트는 3:1 이상을 권장합니다.")
            EducationCard(title: "실기기 검수", body: "인쇄물/프로젝터/실내 조명 환경에서 최종 점검해야 실제 가독성을 보장할 수 있습니다.")
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

private struct SmallCard: View {
    let title: String
    let body: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption.weight(.bold))
                .foregroundStyle(UnseenTheme.text)
                .lineLimit(2)
            Text(body)
                .font(.caption)
                .foregroundStyle(UnseenTheme.dim)
                .lineSpacing(2)
                .lineLimit(3)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(UnseenTheme.surface2)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

private struct DemoStep: View {
    let time: String
    let title: String
    let detail: String

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Text(time)
                .font(.caption2.monospaced().weight(.semibold))
                .foregroundStyle(UnseenTheme.accent)
                .frame(width: 74, alignment: .leading)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(UnseenTheme.text)
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(UnseenTheme.dim)
            }

            Spacer(minLength: 0)
        }
        .padding(10)
        .background(UnseenTheme.surface2)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

struct EducationCard: View {
    let title: String
    let body: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(UnseenTheme.text)
            Text(body)
                .font(.caption)
                .foregroundStyle(UnseenTheme.dim)
                .lineSpacing(2)
        }
        .padding(12)
        .background(UnseenTheme.surface2)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}
