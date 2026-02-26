import SwiftUI

struct EducationCardsSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    Text("디자이너를 위한 접근성 카드")
                        .font(.system(.title2, design: .serif, weight: .regular))
                        .foregroundStyle(UnseenTheme.text)

                    EducationCard(title: "규칙 1", body: "색만으로 상태를 전달하지 말고 아이콘·텍스트를 함께 사용하세요.")
                    EducationCard(title: "규칙 2", body: "일반 텍스트 대비 4.5:1 이상(큰 텍스트 3:1 이상)을 기본으로 점검하세요.")
                    EducationCard(title: "규칙 3", body: "초록/빨강 쌍은 대체 색상(주황/파랑) 조합을 우선 고려하세요.")
                    EducationCard(title: "규칙 4", body: "실기기 조명/거리 환경에서 마지막 검수를 반드시 수행하세요.")
                    EducationCard(title: "규칙 5", body: "최종 제출물에는 접근성 검수 과정을 명시해 신뢰도를 높이세요.")
                }
                .padding(20)
            }
            .background(UnseenTheme.bg.ignoresSafeArea())
            .navigationTitle("교육 카드")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("닫기") { dismiss() }
                        .accessibilityLabel("교육 카드 닫기")
                }
            }
        }
    }
}
