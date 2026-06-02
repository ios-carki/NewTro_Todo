<!--
<p align="center">
    <img width="979" alt="스크린샷 2023-01-13 오후 11 02 34" src="https://user-images.githubusercontent.com/44957712/212338109-d176b9b1-b891-4211-b2a1-363042c1288b.png">
</p>
***
-->
<p align="center">
<img width="1137" alt="NewTro Todo" src="https://user-images.githubusercontent.com/44957712/208224375-06213fc4-b612-4650-a4e6-f3f9843fbc51.png">
</p>

<h1 align="center">NewTro Todo · 뉴트로 투두</h1>

<p align="center">
  레트로 픽셀아트 감성의 UI로 메모 · Todo 관리 · 위젯을 제공하는 iOS Todo 앱<br/>
  <sub>기존 UIKit/MVC 앱을 SwiftUI + Clean Architecture 로 전면 리팩토링한 프로젝트</sub>
</p>

<p align="center">
  <img alt="Platform" src="https://img.shields.io/badge/iOS-16.0%2B-blue?logo=apple">
  <img alt="Swift" src="https://img.shields.io/badge/Swift-5-orange?logo=swift">
  <img alt="UI" src="https://img.shields.io/badge/UI-SwiftUI-green">
  <img alt="Architecture" src="https://img.shields.io/badge/Architecture-Clean%20%2B%20MVVM-informational">
  <img alt="License" src="https://img.shields.io/badge/License-All%20Rights%20Reserved-lightgrey">
</p>

<!-- TODO: App Store 출시 링크 추가 -->
<!-- <p align="center"><a href="https://apps.apple.com/app/idXXXXXXXXX">App Store 에서 다운로드</a></p> -->

***

> ⚠️ **이 저장소는 열람·학습·참고 목적으로 공개**되어 있으며 오픈소스가 아닙니다.
> 개인 식별·서명 정보와 Firebase 설정은 포함돼 있지 않아 **클론한 코드를 그대로
> 빌드해 App Store 에 출시할 수 없으며**, 라이선스상으로도 복제·재배포·출시가
> 금지됩니다. → [LICENSE](LICENSE)

## ✨ 주요 기능

- **단일 화면 Todo CRUD** — App Depth 를 낮춰 한 화면에서 할 일 추가·완료·미루기·정렬
- **중요도 표시** — 우선순위에 따른 텍스트 컬러 구분
- **퀵메모** — 하루 단위의 짧은 메모 작성
- **커스텀 캘린더** — 날짜 이동 + 선택 날짜의 Todo 개수 확인 (SwiftUI 자체 구현)
- **루틴(Routine)** — 반복 할 일 템플릿 관리
- **통계 & 업적** — 사용 기록 기반 스코어·성취 시스템
- **리워드 경제** — 동전/지갑 기반 마스코트 해금
- **위젯** — 홈 화면에서 오늘의 Todo 확인 (WidgetKit)
- **로컬 알림** — 권한 상태·앱 생명주기에 따른 알림 분기 처리
- **다국어** — 한국어 · 영어 · 일본어 · 중국어(간체)
- **데이터 영속성** — 로컬 Realm DB (클라우드 미사용, 오프라인 동작)

## 🛠 Tech Stack

| 분류 | 사용 기술 |
|------|-----------|
| 언어 / 최소 버전 | Swift 5, iOS 16.0+ |
| UI | SwiftUI, WidgetKit |
| 아키텍처 | Clean Architecture + MVVM + Coordinator + DI Container |
| 비동기 | async/await (기본), Combine (UI 바인딩/스트림) |
| 영속성 | Realm (realm-swift v20) |
| 백엔드 SDK | Firebase — Messaging(푸시), Crashlytics(크래시 리포팅) |
| 프로젝트 관리 | Tuist (멀티모듈 / 프로젝트 생성) |

## 🏛 Architecture

계층 의존 방향은 **단방향**이며 위반하지 않습니다.

```
Presentation (View + ViewModel + Coordinator)
        ↓
Domain (Entity + UseCase + Repository Protocol)
        ↑ (구현체 주입)
Data (Repository 구현 + Storage + DTO)
```

- **Domain** 계층은 `Foundation` 만 import — SwiftUI/Realm 등 외부 프레임워크 금지
- View 는 Repository/Storage 를 직접 호출하지 않음: `View → ViewModel → UseCase → Repository`
- 모든 외부 의존성은 Protocol 추상화 + 생성자 주입 (`Application/DIContainer`)
- 상세 규칙은 [CLAUDE.md](CLAUDE.md) 참고

## 📂 Project Structure

```
NewTro_Todo/
├── Application/    # AppDelegate, AppCoordinator, DIContainer
├── Core/           # Extensions, Constants, CustomColor/Font
├── Domain/         # Entity, UseCase, Repository(Protocol)
├── Data/           # Repository(구현), Storage(Realm Object), DTO
├── Presentation/   # Splash · Welcome · Onboarding · Main · Memo
│                   #  · Routine · Stats · Achievement · Settings
└── Resources/      # Assets, Fonts, Localizing
NewtroWidget/       # WidgetKit Extension (App 과 Realm 스키마 공유)
```

## ⚙️ 빌드 설정 (Setup)

> 이 저장소에는 개인 식별·서명 정보와 Firebase 설정이 포함돼 있지 않습니다.
> 빌드하려면 본인 소유의 값을 직접 채워야 합니다.

**사전 요구사항** — Xcode 16+, [Tuist](https://tuist.io)

**1. 서명 · 번들 ID**
```bash
cp Config/Signing.example.xcconfig Config/Signing.xcconfig
```
| 키 | 설명 |
|----|------|
| `NEWTRO_DEVELOPMENT_TEAM` | Apple Developer 팀 ID (10자 영숫자) |
| `NEWTRO_BUNDLE_ID` | 본인 소유 번들 식별자 (예: `com.yourname.newtro-todo`) |

이 파일은 `.gitignore` 로 추적 제외되며, 없으면 `tuist generate` 가 실패합니다.

**2. Firebase**

[Firebase Console](https://console.firebase.google.com) 에서 iOS 앱 등록 후 발급된
`GoogleService-Info.plist` 를 `NewTro_Todo/` 에 저장합니다.
(템플릿: `NewTro_Todo/GoogleService-Info.example.plist`, 실제 파일은 추적 제외)

**3. 생성 & 빌드**
```bash
tuist install            # 최초 1회 / SPM 패키지 변경 시
tuist generate --no-open

xcodebuild -workspace NewTro_Todo.xcworkspace -scheme NewTro_Todo \
  -destination 'platform=iOS Simulator,name=iPhone 16'
```

## 🔐 보안

이 앱은 **사용자 데이터를 클라우드에 저장하지 않습니다** — 모든 Todo/메모는 기기
내부 Realm DB 에만 존재합니다. Firebase 사용 범위는 **푸시 알림(FCM)** 과
**크래시 리포팅(Crashlytics)** 으로 한정됩니다 (Firestore/Auth/Storage 미사용).

`GoogleService-Info.plist` 의 iOS 키는 앱 번들에 동봉돼 배포되는 식별자라
암호학적 비밀이 아니며, 추적 제외는 노출 최소화 목적입니다. 키 오남용 방지는
파일을 숨기는 것이 아니라 **서버 측 통제**(API 키의 번들 ID 제한, 미사용
Firebase 서비스 비활성화)로 수행합니다.

## 🚀 버전 관리 / 출시

- 현재 버전: **2.0.0**
- 버전 규칙·태깅 절차: [RELEASING.md](RELEASING.md)
- 변경 이력: [CHANGELOG.md](CHANGELOG.md)

## 📄 License

Copyright (c) 2026 Carki. **All Rights Reserved.**
열람·참고용 공개이며 복제·수정·재배포·출시를 금지합니다. → [LICENSE](LICENSE)
