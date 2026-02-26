# Unseen

**SSC 2026 제출용 iPad 앱(.swiftpm)**

> See what 300 million people can't.

Unseen은 iPad 카메라로 실제 세계(포스터, 교재, 간판, UI)를 비추면,
색각이상 시야 시뮬레이션 + 텍스트 명도대비(WCAG) 진단을 실시간으로 제공하는 접근성 도구입니다.

## 왜 앱이어야 하나
- **카메라가 없으면 존재할 수 없음**: 실물을 즉시 진단해야 함
- **웹/문서 대체 불가**: 실시간 프레임 처리 + 현장 사용성
- **반복 사용 도구**: 디자이너/교육자가 작업물 검수 루틴으로 사용

## 현재 구현
- 실시간 카메라 프레임 수집 (AVFoundation)
- 색각이상 모드 토글 (Normal / Deuteranopia / Protanopia / Tritanopia)
- 색각 시뮬레이션 필터 적용 (CoreImage color matrix)
- 텍스트 인식 (Vision OCR)
- 텍스트 영역 명도대비 계산 + PASS/FAIL 오버레이 (WCAG 기준)
- 화면 탭 시 색상 상세(HEX/RGB, 모드별 변환값, 대체 색상 제안)
- 카메라 권한 불가 시 샘플 이미지 폴백

## 프로젝트 구조
- `unseen.swiftpm/Package.swift`
- `unseen.swiftpm/ContentView.swift`
- `unseen.swiftpm/MyApp.swift`
- `unseen.swiftpm/Supporting/Info.plist`

## 실행
Xcode 또는 Swift Playgrounds에서 `unseen.swiftpm` 폴더를 열어 실행하세요.
