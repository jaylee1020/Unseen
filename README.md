# Unseen

**SSC 2026 제출용 iPad 앱 (`.swiftpm`)**

> See what 300 million people can't.

Unseen은 iPad 카메라로 실물(포스터, 교재, 간판, 화면)을 비추면 색각이상 시야 시뮬레이션과 텍스트 대비 진단을 동시에 보여주는 접근성 검수 앱입니다.

## 왜 앱이어야 하나
- 카메라 실시간 입력이 핵심이므로 웹 문서/정적 필터로 대체할 수 없습니다.
- 디자인/교육 현장에서 즉시 확인하고 반복 사용 가능한 도구입니다.

## 현재 구현 기능
- AVFoundation 기반 실시간 카메라 프레임 처리
- 4개 모드 시뮬레이션: `Normal / Deuteranopia / Protanopia / Tritanopia`
- CoreImage 색변환(`SimulationEngine`) 기반 실시간 시야 변환
- Vision OCR + WCAG 대비 계산 + PASS/FAIL 오버레이
- 탭 색상 상세 분석(HEX/RGB, 모드별 변환값, 대체 색상 제안)
- FAIL 지점 탭 시 CoreHaptics 피드백
- 프레임 고정/재개 및 샘플 모드(권한 거부/카메라 불가 폴백)
- 교육 카드 시트(스와이프/버튼)
- VoiceOver 라벨/힌트 및 Dynamic Type 대응 레이아웃

## 코드 구조 (모듈 분리)
- `unseen.swiftpm/ContentView.swift`: 앱 엔트리 화면 래퍼
- `unseen.swiftpm/CameraScreen.swift`: 메인 UI
- `unseen.swiftpm/CameraAnalyzerViewModel.swift`: 카메라/분석 파이프라인
- `unseen.swiftpm/SimulationEngine.swift`: 시뮬레이션 엔진 프로토콜 + CI/Metal 백엔드
- `unseen.swiftpm/Models.swift`: 도메인 모델 + 분석 상수
- `unseen.swiftpm/ColorInspectionSheet.swift`: 탭 상세 시트
- `unseen.swiftpm/EducationCardsSheet.swift`: 교육 카드 시트
- `unseen.swiftpm/Theme.swift`: 공통 컬러 테마
- `unseen.swiftpm/Supporting/Info.plist`: 카메라 권한 문구

## 실행
- Xcode 또는 Swift Playgrounds에서 `unseen.swiftpm` 폴더를 열어 실행합니다.
- 카메라 기능 검증은 실기기(iPad)에서 진행해야 합니다.
