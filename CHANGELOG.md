# Changelog

이 프로젝트의 주요 변경 사항을 기록합니다.
포맷은 [Keep a Changelog](https://keepachangelog.com/ko/1.1.0/), 버전은
[Semantic Versioning](https://semver.org) 을 따릅니다.

규칙: 작업하면서 `[Unreleased]` 에 항목을 누적하고, 출시 시점에 버전 섹션으로
확정합니다. 자세한 절차는 [RELEASING.md](RELEASING.md) 참고.

## [Unreleased]

(다음 버전 작업 항목을 여기 누적)

## [2.0.0] - 2026-06-06

### Changed
- 기존 UIKit + MVC 코드를 SwiftUI + Clean Architecture + MVVM + Coordinator 로
  전면 리팩토링.
- Realm realm-swift v20 로 업그레이드 (Tuist `.external` 통합, Xcode 26 호환).
- Firebase Crashlytics 도입 (DEBUG 빌드 수집 비활성), FCM(푸시) 제거.
- FSCalendar 등 UIKit 의존 라이브러리 제거 및 SwiftUI 커스텀 컴포넌트로 대체.

### Added
- 위젯 전면 재설계: "오늘" 위젯(Small 플립 달력 / Medium 투두 리스트 /
  Large 월 달력) + "메모" 위젯(Large 포스트잇).
- 루틴(반복 일정) 규칙 + 루틴 생성 Todo 의 백업/복구 지원.
- 레포 공개 운영 문서/템플릿: `README` 셋업 가이드, `LICENSE`(All Rights
  Reserved), `RELEASING.md`, `CHANGELOG.md`, `Config/Signing.example.xcconfig`,
  `GoogleService-Info.example.plist`.
- 다국어 지원 (한국어/영어/일본어/중국어 간체).

### Fixed
- 시간대 변경 시 그날 Todo 가 사라지거나 루틴 Todo 가 중복 생성되던 문제
  (정확매칭 → 범위 쿼리, 저장 방식·스키마 불변).
- 일본어 등에서 텍스트가 잘리거나 줄바꿈되던 i18n 레이아웃 문제(자동 축소).

### Security
- `GoogleService-Info.plist` 및 서명·식별 정보(`DEVELOPMENT_TEAM`, 번들 ID)를
  추적 제외된 로컬 xcconfig(`Config/Signing.xcconfig`)로 분리. public 클론은
  자신의 값을 채워야 빌드 가능. 실제 방어는 서버 측 API 키 제한 · App Check ·
  Security Rules 로 수행 예정.

## [1.2.7] - 리팩토링 이전 baseline

- 리팩토링 이전 UIKit 기반 스토어 출시 버전. 변경 이력 추적 시작점(구 `.xcodeproj` 구조).

[Unreleased]: https://github.com/ios-carki/NewTro_Todo/compare/v2.0.0...HEAD
[2.0.0]: https://github.com/ios-carki/NewTro_Todo/compare/v1.2.7...v2.0.0
[1.2.7]: https://github.com/ios-carki/NewTro_Todo/releases/tag/v1.2.7
