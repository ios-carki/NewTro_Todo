# 출시 & 버전 관리 (Releasing)

NewTro Todo 의 App Store 출시 버전을 Git/GitHub 에서 관리하는 규칙입니다.

## 1. 버전 체계

[Semantic Versioning](https://semver.org) 을 따르며, Xcode 빌드 설정과 1:1 매핑합니다.

| 항목 | Project.swift 키 | 예시 | 의미 |
|------|------------------|------|------|
| 마케팅 버전 | `MARKETING_VERSION` | `2.0.0` | 사용자에게 표시되는 버전. `MAJOR.MINOR.PATCH` |
| 빌드 번호 | `CURRENT_PROJECT_VERSION` | `1` | 동일 마케팅 버전 내 업로드마다 +1 (심사 리젝 재업로드 등) |

- **MAJOR**: 호환 깨지는 큰 변화 (예: 전면 리팩토링, 데이터 구조 대개편)
- **MINOR**: 하위 호환되는 기능 추가
- **PATCH**: 버그 수정
- 두 값 모두 **Project.swift 가 단일 출처**다. Xcode GUI 에서 직접 바꾸지 말 것
  (`tuist generate` 시 덮어써짐).
- 앱 본체와 위젯의 버전은 **항상 동일**해야 한다 (다르면 App Store 리젝).

## 2. 브랜치 ↔ 릴리스

```
main              ← 출시된(스토어에 올라간) 코드. 릴리스마다 태그. 항상 빌드 가능
 │
 ├─ release/x.y.z ← 출시 직전 "동결" 후 안정화 전용. 막판 변경은 여기서만
 │
refactor-base     ← 다음 버전 통합 브랜치(= develop 역할). 새 기능은 모두 여기로
 │
 ├─ feature/*     ← 기능/수정 단위 작업 → refactor-base 로 PR
 │
 └─ hotfix/x.y.z  ← 라이브 긴급 버그. main(태그)에서 분기 → main 으로
```

- 평상시 작업은 `feature → refactor-base` PR.
- **`main` 에 머지되는 시점 = 릴리스 시점.** main 의 각 릴리스 커밋에 태그를 단다.
- 태그가 "이 커밋이 곧 그 버전"이라는 단일 진실(single source of truth).
- 리팩토링 종료 후 `refactor-base` 는 `develop` 으로 개명 권장(역할이 곧 develop).

## 3. 릴리스 절차

1. **버전 올리기** — `Project.swift` 의 `MARKETING_VERSION`(필요 시 `CURRENT_PROJECT_VERSION`) 수정
   ```bash
   tuist generate --no-open   # 변경 반영
   ```
2. **CHANGELOG 갱신** — [CHANGELOG.md](CHANGELOG.md) 의 `[Unreleased]` 항목을 새 버전 섹션으로 확정
3. **머지** — 해당 변경을 `main` 에 머지 (PR)
4. **아카이브 & 업로드** — Xcode Archive → App Store Connect 업로드 → 심사 제출
5. **태그 & GitHub Release** — main 머지 커밋에 태그
   ```bash
   git checkout main && git pull origin main
   git tag -a v2.0.0 -m "NewTro Todo 2.0.0"
   git push origin v2.0.0
   gh release create v2.0.0 --title "v2.0.0" --notes-file <(sed -n '/## \[2.0.0\]/,/## \[/p' CHANGELOG.md)
   ```
   - 태그 네이밍: `vMAJOR.MINOR.PATCH` (예: `v2.0.0`, `v2.1.0`, `v2.1.1`)
   - 빌드 재업로드(빌드번호만 +1)는 태그를 새로 만들지 않고 기존 버전 태그 유지 가능
     (필요 시 `v2.0.0-build2` 형태로 구분)

### 출시 직전 "동결" — release 브랜치

이번 버전 기능이 `refactor-base` 에 다 모이면, **출시분만 담은** `release/x.y.z` 브랜치를
끊어 그 위에서 마무리한다. (`refactor-base` 에는 다음 버전용 미완성 기능이 섞여 있어
거기서 바로 빌드하면 안 익은 코드가 따라온다.)

```bash
git checkout refactor-base && git pull origin refactor-base
git checkout -b release/2.0.0
# 버전 확정 + CHANGELOG [Unreleased] → [2.0.0] 날짜 기입 + tuist generate
git push origin release/2.0.0
```

- **막판 변경(버그 픽스·문구·QA 대응)은 `refactor-base` 가 아니라 이 release 브랜치에서** 처리한다.
  ```bash
  git checkout release/2.0.0
  git checkout -b fix/막판-수정
  gh pr create --base release/2.0.0 --head fix/막판-수정
  # 같은 마케팅 버전 재업로드면 CURRENT_PROJECT_VERSION 만 +1 → 재아카이브
  ```
- QA 통과 후 `release/x.y.z` → `main` PR 머지 → 태그(§3) → **백머지**:
  ```bash
  git checkout refactor-base && git merge main && git push origin refactor-base
  ```

## 4. 핫픽스 (이미 출시된 버전의 긴급 버그)

라이브 코드(=`main` 의 최신 태그)에서 분기해 **PATCH 만** 올린다. 기능 추가 금지(최소 변경).

```bash
git checkout main && git pull origin main      # 출시된 코드에서 출발
git checkout -b hotfix/2.0.1
# 최소 수정 + MARKETING_VERSION PATCH +1 (2.0.0 → 2.0.1) + CHANGELOG
gh pr create --base main --head hotfix/2.0.1
# 머지 → 태그 v2.0.1 → Archive 업로드(필요 시 App Store Connect 에서 신속 심사 요청)
git checkout refactor-base && git merge main && git push origin refactor-base  # develop 에도 반드시 반영
```

## 5. 체크리스트

- [ ] `refactor-base` 에서 `release/x.y.z` 분기 (출시분 동결)
- [ ] `MARKETING_VERSION` / `CURRENT_PROJECT_VERSION` 갱신 (앱·위젯 동일)
- [ ] `tuist generate --no-open` 재생성
- [ ] CHANGELOG `[Unreleased]` → 버전 섹션 확정 (날짜 기입)
- [ ] 전체 테스트 그린 + 위젯 실기기 QA
- [ ] `release/x.y.z` → `main` 머지
- [ ] Archive → App Store Connect 업로드 → 심사 제출
- [ ] `vX.Y.Z` 태그 push + GitHub Release 작성
- [ ] `main` → `refactor-base` 백머지
- [ ] (Realm 스키마 변경 시) 마이그레이션 + 기존 사용자 데이터 보존 검증

## 6. 출시 이력 (태그)

| 태그 | 마케팅 버전 | 비고 |
|------|-------------|------|
| `v1.2.7` | 1.2.7 | 리팩토링 이전 UIKit 기반 **스토어 출시 baseline**. 버전 추적 시작점 |
| `v2.0.0` | 2.0.0 | SwiftUI + Clean Architecture 전면 리팩토링 (예정) |

- 리팩토링 이전 버전은 구 `.xcodeproj`(Tuist 이전) 구조이며, `main` 의 해당 커밋에 태그로 보존한다.
