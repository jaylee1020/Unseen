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

            Text("An app that cannot exist without a camera. Point it at real-world items — posters, signs, textbooks, UI — and get real-time color vision simulation + WCAG contrast diagnostics.")
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
                Text("Camera Viewfinder")
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
                        Text("Waiting for camera frame...")
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
                            .accessibilityLabel("\(finding.pass ? "Pass" : "Fail") text: \(finding.text)")
                            .accessibilityValue("Contrast \(String(format: "%.2f", finding.ratio))")
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
                .accessibilityLabel("Live camera diagnostic view")
                .accessibilityHint("Tap to inspect color details.")
            }
            .frame(height: 300)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(UnseenTheme.border, lineWidth: 1)
            }

            Text("Tap the view to inspect color details and alternatives.")
                .font(.footnote)
                .foregroundStyle(UnseenTheme.dim)

            HStack(spacing: 8) {
                Capsule()
                    .fill(UnseenTheme.border)
                    .frame(width: 34, height: 4)
                Text("Swipe up for education cards")
                    .font(.caption)
                    .foregroundStyle(UnseenTheme.dim)
                Spacer()
                Button("Open") {
                    showEducationSheet = true
                }
                .font(.caption.monospaced().weight(.semibold))
                .foregroundStyle(UnseenTheme.accent)
                .accessibilityLabel("Open education cards")
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
        .unseenCard()
    }

    private var controlsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Live Diagnostic Settings")
                .font(.caption.monospaced().weight(.semibold))
                .foregroundStyle(UnseenTheme.accent)

            Picker("Vision Mode", selection: $vm.mode) {
                ForEach(VisionMode.allCases) { mode in
                    Text(mode.shortLabel).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .accessibilityLabel("Vision mode selector")
            .accessibilityHint("Switch between Normal, Red-Green, Protanopia, and Tritanopia modes.")

            Toggle("Text Recognition + WCAG Contrast Analysis", isOn: $vm.analyzeText)
                .tint(UnseenTheme.accent)
                .accessibilityLabel("Text recognition and contrast analysis")

            Button {
                vm.isFrozen.toggle()
                if vm.isFrozen {
                    vm.statusText = "Frame frozen"
                } else {
                    vm.statusText = vm.useSampleFallback ? "Sample mode" : "Live camera analysis"
                }
            } label: {
                Label(vm.isFrozen ? "Resume Analysis" : "Freeze Frame", systemImage: vm.isFrozen ? "play.fill" : "pause.fill")
                    .font(.subheadline.weight(.semibold))
            }
            .buttonStyle(.bordered)
            .tint(UnseenTheme.accent)
            .accessibilityHint("Freeze the current frame for detailed inspection.")

            HStack(alignment: .firstTextBaseline, spacing: 10) {
                Text(vm.statusText)
                    .font(.footnote)
                    .foregroundStyle(UnseenTheme.dim)
                    .accessibilityLabel("Status")
                    .accessibilityValue(vm.statusText)

                Spacer()

                Button("Sample Mode") {
                    vm.activateSampleFallback(reason: "Sample mode (manual)")
                }
                .font(.caption.monospaced().weight(.semibold))
                .foregroundStyle(UnseenTheme.blue)
                .accessibilityHint("Switch to demo view without camera.")
            }

            if vm.permissionDenied {
                Button("Open Camera Permission in Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                .font(.subheadline.weight(.semibold))
                .padding(.top, 2)
                .accessibilityHint("Opens Settings to change camera permission.")
            }
        }
        .unseenCard()
    }

    private var findingsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Diagnostic Results")
                .font(.caption.monospaced().weight(.semibold))
                .foregroundStyle(UnseenTheme.accent)

            if vm.findings.isEmpty {
                Text("PASS/FAIL results will appear here when text is recognized.")
                    .font(.footnote)
                    .foregroundStyle(UnseenTheme.dim)
            } else {
                let (failCount, worstRatio) = vm.findings.reduce(into: (0, Double.infinity)) { result, f in
                    if !f.pass { result.0 += 1 }
                    result.1 = min(result.1, f.ratio)
                }
                let displayRatio = worstRatio == .infinity ? 0.0 : worstRatio

                HStack(spacing: 8) {
                    Text(failCount == 0 ? "ALL PASS" : "FAIL \(failCount)")
                        .font(.caption2.monospaced().weight(.bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(failCount == 0 ? UnseenTheme.green : UnseenTheme.red)
                        .clipShape(Capsule())
                        .accessibilityLabel(failCount == 0 ? "All passed" : "\(failCount) failed")

                    Text("worst \(String(format: "%.2f", displayRatio))")
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
                    .accessibilityLabel("Text: \(finding.text)")
                    .accessibilityValue("\(finding.pass ? "Pass" : "Fail"), contrast \(String(format: "%.2f", finding.ratio))")
                }
            }
        }
        .unseenCard()
    }

    private var whyAppSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Why this must be an app")
                .font(.caption.monospaced().weight(.semibold))
                .foregroundStyle(UnseenTheme.accent)

            Text("An app that cannot exist without a camera")
                .font(.system(.title2, design: .serif, weight: .regular))
                .foregroundStyle(UnseenTheme.text)

            Text("Real-world items need instant diagnosis on the spot — web tools or Photoshop filters can't replace that. The key value is a repeatable inspection tool for designers and educators.")
                .font(.callout)
                .foregroundStyle(UnseenTheme.dim)
                .lineSpacing(2)

            HStack(spacing: 10) {
                SmallCard(title: "Real-World", content: "Diagnose physical accessibility, not just digital files")
                SmallCard(title: "Real-Time", content: "Instant results as you point")
                SmallCard(title: "Repeatable", content: "Build accessibility checks into your routine")
            }
        }
        .unseenCard()
    }

    private var demoFlowSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("3-min demo flow")
                .font(.caption.monospaced().weight(.semibold))
                .foregroundStyle(UnseenTheme.accent)

            DemoStep(time: "0:00-0:15", title: "App Launch", detail: "One-line intro, then straight to camera")
            DemoStep(time: "0:15-0:50", title: "CVD Simulation", detail: "Toggle modes to experience red-green conflict")
            DemoStep(time: "0:50-1:40", title: "PASS/FAIL Diagnosis", detail: "Auto text recognition + WCAG contrast check")
            DemoStep(time: "1:40-2:20", title: "Tap Detail Analysis", detail: "HEX/RGB + per-mode conversion + alternative colors")
            DemoStep(time: "2:20-3:00", title: "Repeatable Value", detail: "Connect to real design review workflows")
        }
        .unseenCard()
    }

    private var educationCardsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Quick Education Cards")
                .font(.caption.monospaced().weight(.semibold))
                .foregroundStyle(UnseenTheme.accent)

            EducationCard(title: "Don't rely on color alone", content: "Use icons and text alongside color to convey status like pass/fail.")
            EducationCard(title: "WCAG Contrast Baseline", content: "Normal text requires 4.5:1 ratio; large text requires 3:1 minimum.")
            EducationCard(title: "Test on real devices", content: "Always do a final check under real lighting, distance, and print conditions.")
        }
        .unseenCard()
    }
}

private struct SmallCard: View {
    let title: String
    let content: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption.weight(.bold))
                .foregroundStyle(UnseenTheme.text)
                .lineLimit(2)
            Text(content)
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
    let content: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(UnseenTheme.text)
            Text(content)
                .font(.caption)
                .foregroundStyle(UnseenTheme.dim)
                .lineSpacing(2)
        }
        .padding(12)
        .background(UnseenTheme.surface2)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}
