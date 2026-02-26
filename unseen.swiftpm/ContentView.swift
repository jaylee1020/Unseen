import SwiftUI

struct ContentView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Unseen")
                        .font(.system(size: 42, weight: .semibold, design: .serif))
                    Text("내가 만든 디자인이 누군가에게는 보이지 않았다.")
                        .font(.system(.title3, design: .serif))
                        .foregroundStyle(.orange)
                    Text("교육 자료·인쇄물·화면을 iPad 카메라로 비추면, 색각이상자의 시야로 실시간 변환하고 문제가 되는 색 조합을 자동으로 잡아내는 접근성 진단 도구")
                        .foregroundStyle(.secondary)
                }

                GroupBox("핵심 기능") {
                    VStack(alignment: .leading, spacing: 10) {
                        Label("실시간 색각이상 시뮬레이션", systemImage: "camera.viewfinder")
                        Label("위험 색조합 자동 감지", systemImage: "exclamationmark.triangle")
                        Label("대체 색상 제안", systemImage: "paintpalette")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 4)
                }

                GroupBox("심사 포인트") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("• 시뮬레이션에서 끝나지 않고 진단 + 처방까지 제공")
                        Text("• 인쇄물/실물 환경에서도 바로 검사 가능")
                        Text("• 디자인 접근성 문제를 현장에서 즉시 해결")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundStyle(.secondary)
                    .padding(.top, 4)
                }
            }
            .padding(20)
        }
        .background(Color(.systemGroupedBackground))
    }
}

#Preview {
    ContentView()
}
