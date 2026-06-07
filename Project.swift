import ProjectDescription

let project = Project(
    name: "NewTro_Todo",
    organizationName: "Carki",
    packages: [
        // Realm 은 Tuist/Package.swift 의 .external 통합으로 이전 (Xcode 26 is_pod 빌드 에러 회피).
        // Firebase 는 native .remote 유지 — .external 로 옮기면 Crashlytics 만 써도 Firestore 가
        // 끌고 오는 gRPC/abseil/protobuf 그래프를 Tuist 가 디코딩하지 못해 generate 가 깨진다.
        // (Firebase 는 is_pod 문제도 없어 native SPM 으로 정상 빌드됨.)
        .remote(url: "https://github.com/firebase/firebase-ios-sdk", requirement: .upToNextMajor(from: "9.6.0")),
    ],
    // 서명·식별 정보(DEVELOPMENT_TEAM / 번들 ID)는 public 레포에 두지 않는다.
    // 추적 제외된 Config/Signing.xcconfig 에서 NEWTRO_DEVELOPMENT_TEAM / NEWTRO_BUNDLE_ID 를 주입.
    // 신규 클론은 Config/Signing.example.xcconfig 를 복사해 자신의 값을 채워야 빌드/서명된다.
    settings: .settings(
        configurations: [
            .debug(name: "Debug", xcconfig: "Config/Signing.xcconfig"),
            .release(name: "Release", xcconfig: "Config/Signing.xcconfig"),
        ]
    ),
    targets: [
        // MARK: - App Target
        .target(
            name: "NewTro_Todo",
            destinations: .iOS,
            product: .app,
            bundleId: "$(NEWTRO_BUNDLE_ID)",
            deploymentTargets: .iOS("16.0"),
            infoPlist: .extendingDefault(with: [
                // Build settings의 MARKETING_VERSION / CURRENT_PROJECT_VERSION을 참조 — Project.swift가 단일 출처.
                "CFBundleShortVersionString": .string("$(MARKETING_VERSION)"),
                "CFBundleVersion": .string("$(CURRENT_PROJECT_VERSION)"),
                // 콜드 스타트 시 검은 깜빡임 제거 — Splash 첫 프레임의 .sky(#7CC7F0)와 동일한 색 에셋을 깔아둠.
                "UILaunchScreen": .dictionary([
                    "UIColorName": .string("LaunchSky"),
                ]),
                "CFBundleDevelopmentRegion": .string("ko"),
                "CFBundleLocalizations": .array([
                    .string("ko"),
                    .string("en"),
                    .string("zh-Hans"),
                    .string("ja"),
                ]),
                "UIAppFonts": .array([
                    .string("Galmuri11-Bold.ttf"),
                    .string("Galmuri11-Condensed.ttf"),
                    .string("PressStart2P-Regular.ttf"),
                ]),
                "UIApplicationSceneManifest": .dictionary([
                    "UIApplicationSupportsMultipleScenes": .boolean(false),
                    "UISceneConfigurations": .dictionary([
                        "UIWindowSceneSessionRoleApplication": .array([
                            .dictionary([
                                "UISceneConfigurationName": .string("Default Configuration"),
                                "UISceneDelegateClassName": .string("$(PRODUCT_MODULE_NAME).SceneDelegate"),
                            ]),
                        ]),
                    ]),
                ]),
                "UTExportedTypeDeclarations": .array([
                    .dictionary([
                        "UTTypeIdentifier": .string("com.carki.newtro.backup"),
                        "UTTypeDescription": .string("NewTro Todo Backup"),
                        "UTTypeConformsTo": .array([.string("public.data")]),
                        "UTTypeTagSpecification": .dictionary([
                            "public.filename-extension": .array([.string("ntbackup")]),
                            "public.mime-type": .array([.string("application/octet-stream")]),
                        ]),
                    ]),
                ]),
                "CFBundleDocumentTypes": .array([
                    .dictionary([
                        "CFBundleTypeName": .string("NewTro Todo Backup"),
                        "CFBundleTypeRole": .string("Editor"),
                        "LSHandlerRank": .string("Owner"),
                        "LSItemContentTypes": .array([.string("com.carki.newtro.backup")]),
                    ]),
                ]),
                "LSSupportsOpeningDocumentsInPlace": .boolean(false),
            ]),
            sources: ["NewTro_Todo/**/*.swift"],
            resources: [
                "NewTro_Todo/Assets.xcassets",
                "NewTro_Todo/Source/Extension/Font/Galmuri11/Galmuri11-Bold.ttf",
                "NewTro_Todo/Source/Extension/Font/Galmuri11/Galmuri11-Condensed.ttf",
                "NewTro_Todo/Source/Extension/Font/PressStart2P/PressStart2P-Regular.ttf",
                "NewTro_Todo/Localizing/**",
                "NewTro_Todo/GoogleService-Info.plist",
            ],
            entitlements: .file(path: "NewTro_Todo/NewTro_Todo.entitlements"),
            scripts: [
                // Crashlytics 가 심볼릭 스택트레이스를 보여주려면 빌드 산출물의 dSYM 을
                // 매 빌드마다 Firebase 서버로 업로드해야 한다. firebase-ios-sdk 가 제공하는
                // run 스크립트가 GoogleService-Info.plist 의 GOOGLE_APP_ID 를 자동 인식.
                // outputPaths 가 없으면 Xcode 가 증분 분석을 못 해 매 빌드 실행한다고 경고하는데,
                // dSYM 업로드는 원래 매 빌드 실행이 정상이므로 의도적으로 명시한다.
                .post(
                    script: #""${BUILD_DIR%/Build/*}/SourcePackages/checkouts/firebase-ios-sdk/Crashlytics/run""#,
                    name: "Crashlytics: Upload dSYM",
                    inputPaths: [
                        "${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}/Contents/Resources/DWARF/${TARGET_NAME}",
                        "$(SRCROOT)/$(BUILT_PRODUCTS_DIR)/$(INFOPLIST_PATH)",
                    ],
                    basedOnDependencyAnalysis: false
                ),
            ],
            dependencies: [
                .external(name: "RealmSwift"),
                // Realm v20: Object 베이스 클래스 RealmSwiftObject 는 ObjC `Realm` 프레임워크에
                // 있어 RealmSwift 만 링크하면 위젯/익스텐션에서 심볼 미해결로 링크 실패한다.
                .external(name: "Realm"),
                .package(product: "FirebaseCrashlytics"),
                .target(name: "NewtroWidget"),
            ],
            settings: .settings(
                base: [
                    "DEVELOPMENT_TEAM": "$(NEWTRO_DEVELOPMENT_TEAM)",
                    // 앱 스토어 표시 마케팅 버전. 새 릴리스 때 올리고 commit.
                    "MARKETING_VERSION": "2.0.0",
                    // 동일 마케팅 버전 내 재업로드 시 +1 (심사 리젝션 재업로드 등).
                    "CURRENT_PROJECT_VERSION": "3",
                    // 디버그 빌드(시뮬레이터·실기기 개발)에서는 dSYM 을 매번 만들지 않으면
                    // 업로드 스크립트가 실패하므로 DWARF with dSYM 으로 고정.
                    "DEBUG_INFORMATION_FORMAT": "dwarf-with-dsym",
                ]
            )
        ),

        // MARK: - Widget Target
        .target(
            name: "NewtroWidget",
            destinations: .iOS,
            product: .appExtension,
            bundleId: "$(NEWTRO_BUNDLE_ID).NewtroWidget",
            deploymentTargets: .iOS("16.0"),
            infoPlist: .extendingDefault(with: [
                "CFBundleShortVersionString": .string("$(MARKETING_VERSION)"),
                "CFBundleVersion": .string("$(CURRENT_PROJECT_VERSION)"),
                // App Store 검증(90360): appExtension 기본 Info.plist 에는 CFBundleDisplayName 이
                // 없어 .app 과 달리 누락된다. 명시하지 않으면 Distribute 시 검증 실패.
                "CFBundleDisplayName": .string("$(PRODUCT_NAME)"),
                "UIAppFonts": .array([
                    .string("Galmuri11-Bold.ttf"),
                    .string("Galmuri11-Condensed.ttf"),
                    .string("PressStart2P-Regular.ttf"),
                ]),
                "NSExtension": .dictionary([
                    "NSExtensionPointIdentifier": .string("com.apple.widgetkit-extension"),
                ]),
            ]),
            sources: [
                "NewtroWidget/**/*.swift",
                // App과 공유하는 파일 — Realm 스키마 일치 보장 (마이그레이션 충돌 방지)
                "NewTro_Todo/Data/Storage/TodoObject.swift",
                "NewTro_Todo/Data/Storage/QuickNoteObject.swift",
                "NewTro_Todo/Data/Storage/TemplateObject.swift",
                "NewTro_Todo/Data/Storage/WalletObject.swift",
                "NewTro_Todo/Data/Storage/RoutineObject.swift",
                "NewTro_Todo/Data/Storage/RealmConfiguration.swift",
                "NewTro_Todo/Source/Extension/DateFormat+Extension.swift",
                "NewTro_Todo/Source/Extension/Date+Extension.swift",
                "NewTro_Todo/Source/Extension/Color+Extension.swift",
                "NewTro_Todo/Source/Extension/Font+Extension.swift",
            ],
            resources: [
                "NewtroWidget/Assets.xcassets",
                "NewTro_Todo/Source/Extension/Font/Galmuri11/Galmuri11-Bold.ttf",
                "NewTro_Todo/Source/Extension/Font/Galmuri11/Galmuri11-Condensed.ttf",
                "NewTro_Todo/Source/Extension/Font/PressStart2P/PressStart2P-Regular.ttf",
                "NewTro_Todo/Localizing/**",
            ],
            entitlements: .file(path: "NewtroWidgetExtension.entitlements"),
            dependencies: [
                .external(name: "RealmSwift"),
                // Realm v20: Object 베이스 클래스 RealmSwiftObject 는 ObjC `Realm` 프레임워크에
                // 있어 RealmSwift 만 링크하면 위젯/익스텐션에서 심볼 미해결로 링크 실패한다.
                .external(name: "Realm"),
            ],
            settings: .settings(
                base: [
                    "DEVELOPMENT_TEAM": "$(NEWTRO_DEVELOPMENT_TEAM)",
                    // 위젯은 메인앱과 동일한 버전이어야 함 (다르면 App Store 리젝).
                    "MARKETING_VERSION": "2.0.0",
                    "CURRENT_PROJECT_VERSION": "3",
                ]
            )
        ),

        // MARK: - Unit Test Target
        .target(
            name: "NewTro_TodoTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "$(NEWTRO_BUNDLE_ID).Tests",
            deploymentTargets: .iOS("16.0"),
            sources: ["NewTro_TodoTests/**/*.swift"],
            dependencies: [
                .target(name: "NewTro_Todo"),
                .external(name: "RealmSwift"),
                // Realm v20: Object 베이스 클래스 RealmSwiftObject 는 ObjC `Realm` 프레임워크에
                // 있어 RealmSwift 만 링크하면 위젯/익스텐션에서 심볼 미해결로 링크 실패한다.
                .external(name: "Realm"),
            ],
            settings: .settings(
                base: ["DEVELOPMENT_TEAM": "$(NEWTRO_DEVELOPMENT_TEAM)"]
            )
        ),

        // MARK: - UI Test Target
        .target(
            name: "NewTro_TodoUITests",
            destinations: .iOS,
            product: .uiTests,
            bundleId: "$(NEWTRO_BUNDLE_ID).UITests",
            deploymentTargets: .iOS("16.0"),
            sources: ["NewTro_TodoUITests/**/*.swift"],
            dependencies: [
                .target(name: "NewTro_Todo"),
            ],
            settings: .settings(
                base: ["DEVELOPMENT_TEAM": "$(NEWTRO_DEVELOPMENT_TEAM)"]
            )
        ),
    ],
    // Runtime uses `String.localized()` extension — Tuist의 자동 생성 TuistStrings를 참조하지 않음.
    // 또한 "시작" / "시작!" 처럼 트레일링 구두점만 다른 키들이 식별자 충돌을 일으키므로 strings 합성을 끔.
    resourceSynthesizers: [.assets(), .fonts(), .plists()]
)
