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
feature → refactor-base (통합) → main (릴리스)
```

- 평상시 작업은 `feature → refactor-base` PR.
- **`main` 에 머지되는 시점 = 릴리스 시점.** main 의 각 릴리스 커밋에 태그를 단다.
- 태그가 "이 커밋이 곧 그 버전"이라는 단일 진실(single source of truth).

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

## 4. 체크리스트

- [ ] `MARKETING_VERSION` / `CURRENT_PROJECT_VERSION` 갱신 (앱·위젯 동일)
- [ ] `tuist generate --no-open` 재생성
- [ ] CHANGELOG `[Unreleased]` → 버전 섹션 확정 (날짜 기입)
- [ ] `main` 머지
- [ ] Archive → App Store Connect 업로드 → 심사 제출
- [ ] `vX.Y.Z` 태그 push + GitHub Release 작성
- [ ] (Realm 스키마 변경 시) 마이그레이션 + 기존 사용자 데이터 보존 검증
