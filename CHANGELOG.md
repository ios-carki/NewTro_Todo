# Changelog

이 프로젝트의 주요 변경 사항을 기록합니다.
포맷은 [Keep a Changelog](https://keepachangelog.com/ko/1.1.0/), 버전은
[Semantic Versioning](https://semver.org) 을 따릅니다.

규칙: 작업하면서 `[Unreleased]` 에 항목을 누적하고, 출시 시점에 버전 섹션으로
확정합니다. 자세한 절차는 [RELEASING.md](RELEASING.md) 참고.

## [Unreleased]

### Added
- 레포 공개 운영을 위한 문서/템플릿: `README` 셋업 가이드, `LICENSE`(All Rights
  Reserved), `RELEASING.md`, `CHANGELOG.md`, `Config/Signing.example.xcconfig`,
  `GoogleService-Info.example.plist`.

### Changed
- 서명·식별 정보(`DEVELOPMENT_TEAM`, 번들 ID)를 추적 제외된 로컬 xcconfig
  (`Config/Signing.xcconfig`)로 분리. public 클론은 자신의 값을 채워야 빌드 가능.

### Security
- `GoogleService-Info.plist` 추적 제외 (노출 최소화). 실제 방어는 서버 측
  API 키 제한 · App Check · Security Rules 로 수행 예정.

## [2.0.0] - 미정

### Changed
- 기존 UIKit + MVC 코드를 SwiftUI + Clean Architecture + MVVM + Coordinator 로
  전면 리팩토링.
- Realm realm-swift v20 로 업그레이드 (Tuist `.external` 통합, Xcode 26 호환).
- Firebase Crashlytics 도입 (DEBUG 빌드 수집 비활성).
- FSCalendar 등 UIKit 의존 라이브러리 제거 및 SwiftUI 커스텀 컴포넌트로 대체.

[Unreleased]: https://github.com/ios-carki/NewTro_Todo/compare/v2.0.0...HEAD
[2.0.0]: https://github.com/ios-carki/NewTro_Todo/releases/tag/v2.0.0
