# Newtro_Todo

뉴트로 투두는 레트로 감성의 UI로 메모, Todo 관리, 위젯을 제공하는 Todo 앱입니다.
해당 프로젝트는 기존에 작성된 코드를 SwiftUI + CleanArchitecture + DI Container로 리펙토링 하기 위함입니다.
---

## Tech Stack

### 기존
- SnapKit, Toast-Swift, FSCalendar, IQKeyboardManager, Zip, realm-swift, AcknowList, firebase-ios-sdk, SwiftUI-Custom-TextField
- UIKit, iOS 15.0+

### 리펙토링 요구사항
- Clean Architecture + MVVM + Coordinator
- 위 Library 중에서 필요없는 라이브러리 모두 삭제 가능
- 기존 UIKit + SnapKit + AutoLayout 기반 UI 코드는 모두 SwiftUI로 대체
- async/await (기본), Combine (UI 바인딩/스트림)
- FSCalendar를 SwiftUI Custom Calendar로 대체
- **realm-swift의 데이터 구조, 속성, 값 변경 및 마이그레이션 적용**
- Tuist를 활용한 Multi Module 학습 및 적용
- 앱에서 쓰이는 Color 새롭게 생성

---

## Architecture

Clean Architecture 계층 의존 방향은 **절대 위반 금지**.

```
Presentation (View + ViewModel + Coordinator)
     ↓
Domain (Entity + UseCase + Repository Protocol)
     ↑ (구현체 주입)
Data (Repository 구현 + Network + DTO)
```

- **Domain 계층**은 `Foundation`만 import. SwiftUI / Alamofire / Combine 등 외부 프레임워크 import 금지.
- View는 Repository / APIClient 직접 호출 금지. 반드시 `View → ViewModel → UseCase → Repository`.
- DTO(Data)와 Entity(Domain)는 분리. 변환은 DTO의 `toDomain()`에서 처리.
- UseCase는 단일 책임. `execute()` 하나만 public.

---

## Project Structure

```
LaborLaw_ChatBot/
├── Application/    # AppCoordinator, DIContainer, AppDelegate
├── Core/           # Extensions, Constants, CustomColor, CustomFont
├── Domain/         # Entities, UseCases, Repositories (Protocol만)
├── Data/           # Repositories (구현), Network, DTOs, Storage
├── Presentation/   # {Feature}/ View + (ViewModel + Combine) + Coordinator / Components
└── Resources/      # Assets, Fonts
```

새 파일 생성 시 이 구조를 따를 것. 구조가 불명확하면 먼저 질문할 것.

## Coding Rules

- Protocol 접미사: `Protocol` (예: `ChatRepositoryProtocol`, 구현체 ``ChatRepositoryProtocolImpl`)
- CustomColor/Font 네이밍: `역할+Color/Font` (예: `mainBackgroundColor`)
- API `snake_case` → Swift `camelCase` 변환은 DTO의 `CodingKeys`에서
- 에러 메시지(사용자 노출용)는 **한국어**
- 접근 제어자 명시, 강제 언래핑(`!`) 금지
- View에 다른 화면의 View를 넣지 말것 / 화면간 분리 철처히 / Components를 최대한 활용할 것.

### async/await vs Combine
- **async/await**: UseCase 실행, 네트워크 호출, 일회성 비동기
- **Combine**: `@Published` 바인딩, 입력 디바운싱, 챗봇 스트리밍 수신

### 금지 사항
- ❌ Completion Handler 패턴 (async/await만)
- ❌ View에서 Repository/UseCase 직접 생성
- ❌ UserDefaults에 토큰 저장 (반드시 Keychain)
- ❌ Domain 계층에서 외부 프레임워크 import
- ❌ Entity와 DTO 혼용
- ❌ Singleton 남발 (DIContainer로 관리)
- ❌ 강제 언래핑(`!`), `try!`, `as!`

## DI

- 모든 외부 의존성은 Protocol로 추상화, 생성자 주입
- 의존성 조립은 `Application/DIContainer/`

## Testing

- UseCase, ViewModel, Repository는 Unit Test 필수
- Mock은 Protocol 기반 수동 작성
- 테스트 메서드명: `test_{시나리오}_{기대결과}`
- 실패 테스트 → 구현 → 리팩터링 순서

## Tuist 중요 규칙

**Swift 파일 생성/삭제 후 반드시 실행**:
```bash
tuist generate --no-open
```
실행하지 않으면 Xcode 프로젝트에 반영되지 않음. SPM 패키지 변경 시 `tuist install && tuist generate --no-open`.

### ⚠️ Project.swift가 Single Source of Truth

**Tuist는 `tuist generate` 실행 시마다 `.xcodeproj`와 `Info.plist`를 새로 생성한다.** Xcode에서 직접 수정한 설정(Info.plist 항목, Launch Screen, Build Settings, SPM Dependencies 등)은 **재생성 시 모두 덮어써진다.**

과거 이슈: `tuist generate` 후 Launch Screen 설정이 사라져 시뮬레이터 UI가 작게 렌더링되는 현상이 발생했음. 원인은 Xcode에서 직접 수정한 Launch Screen 설정이 재생성 과정에서 초기화된 것.

**모든 프로젝트 설정은 반드시 `Project.swift`에 선언할 것.** Xcode GUI에서 직접 수정 금지.

**⚠️ Launch Screen 관련 주의**: `UILaunchScreen` Dict를 Info.plist에 명시하지 않으면 iOS가 호환 모드로 앱을 렌더링하여 시뮬레이터/기기에서 UI가 작게 보인다. 이 증상이 발생하면 Info.plist에 `UILaunchScreen` 키가 있는지 먼저 확인할 것.

### Project.swift 필수 선언 사항

- **Info.plist 항목**: `InfoPlist.extendingDefault(with:)`로 명시
- **Launch Screen**: `launchScreen`에 스토리보드 또는 Info.plist Dict 형태로 명시 (아래 예시 참고)
- **SPM Dependencies**: `packages` + `dependencies`에 명시
- **Build Settings**: `settings`에 명시 (Bundle ID, Deployment Target, Swift Version 등)
- **리소스**: `resources`에 `.xcassets`, `.storyboard`, 커스텀 폰트 등 명시

### 디버깅 체크리스트

`tuist generate` 후 설정이 사라진 것 같으면:

1. **Info.plist 내용 확인**: `Derived/InfoPlists/LaborLaw_ChatBot-Info.plist` 파일을 열어 필요한 키가 있는지 확인
2. **SPM 의존성 확인**: Xcode Project Navigator의 Package Dependencies 섹션에 등록되어 있는지
3. **Launch Screen 작동 확인**: 시뮬레이터에서 UI 크기가 정상인지 (작게 보이면 `UILaunchScreen` 누락)
4. 누락된 항목이 있으면 **Xcode에서 고치지 말고 `Project.swift`를 수정** 후 재생성
5. 캐시 꼬임이 의심되면: `tuist clean && tuist install && tuist generate --no-open`

## Commands

```bash
# Tuist 프로젝트 재생성 (Swift 파일 추가/삭제 후 반드시 실행)
tuist generate --no-open

# SPM 패키지 변경 시
tuist install && tuist generate --no-open

# 빌드
xcodebuild -workspace NewTro_Todo.xcworkspace -scheme NewTro_Todo -destination 'platform=iOS Simulator,name=iPhone 16'

# 테스트
xcodebuild test -workspace NewTro_Todo.xcworkspace -scheme NewTro_Todo -destination 'platform=iOS Simulator,name=iPhone 16'
```

---

## Git Workflow

### 브랜치 전략

```
main
 └── refactor                         ← 리펙토링 통합 브랜치 (모든 PR의 base)
      ├── refactor/tuist
      ├── refactor/domain
      ├── refactor/data
      ├── refactor/di-coordinator
      ├── refactor/presentation-splash
      ├── refactor/presentation-onboarding
      ├── refactor/presentation-main
      ├── refactor/presentation-calendar
      ├── refactor/presentation-setting
      └── refactor/widget
```

- 각 `refactor/{feature}` 브랜치는 **항상 `refactor`에서 분기**
- 작업 완료 → `refactor/{feature}` → PR → `refactor` merge
- 전체 완료 → `refactor` → PR → `main` 최종 merge

### 브랜치 네이밍

| 브랜치 | 작업 내용 |
|--------|----------|
| `refactor/tuist` | Tuist 멀티모듈 설정 |
| `refactor/domain` | Domain 계층 (Entity, UseCase, Protocol) |
| `refactor/data` | Data 계층 (RealmRepository, Migration) |
| `refactor/di-coordinator` | DIContainer + AppCoordinator |
| `refactor/presentation-splash` | Splash 화면 SwiftUI 전환 |
| `refactor/presentation-onboarding` | Onboarding 화면 SwiftUI 전환 |
| `refactor/presentation-main` | Main 화면 SwiftUI 전환 |
| `refactor/presentation-calendar` | SwiftUI Custom Calendar (FSCalendar 제거) |
| `refactor/presentation-setting` | Setting 화면 SwiftUI 전환 |
| `refactor/widget` | Widget 리펙토링 |

### 새 작업 브랜치 시작

```bash
git checkout refactor
git pull origin refactor
git checkout -b refactor/{feature}
```

### 작업 완료 후 PR 생성

```bash
git push origin refactor/{feature}
gh pr create --base refactor --head refactor/{feature} --title "refactor: {feature} 설명"
```

### refactor 최신화 후 현재 브랜치에 반영

```bash
git checkout refactor
git pull origin refactor
git checkout refactor/{feature}
git rebase refactor
```

### 최종 main merge (전체 완료 후)

```bash
gh pr create --base main --head refactor --title "refactor: 전체 리펙토링 완료"
```
