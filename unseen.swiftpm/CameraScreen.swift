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
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Unseen")
                    .font(.system(.title, design: .serif, weight: .regular))
                    .foregroundStyle(UnseenTheme.text)

                Text("See what 300 million people can't.")
                    .font(.subheadline)
                    .italic()
                    .foregroundStyle(UnseenTheme.accent)
            }
            Spacer()
        }
        .padding(16)
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
