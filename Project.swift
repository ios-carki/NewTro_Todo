import ProjectDescription

let project = Project(
    name: "NewTro_Todo",
    organizationName: "Carki",
    packages: [
        .remote(url: "https://github.com/realm/realm-swift.git", requirement: .exact("10.30.0")),
        .remote(url: "https://github.com/firebase/firebase-ios-sdk", requirement: .upToNextMajor(from: "9.6.0")),
    ],
    targets: [
        // MARK: - App Target
        .target(
            name: "NewTro_Todo",
            destinations: .iOS,
            product: .app,
            bundleId: "com.jun.NewTro-Todo",
            deploymentTargets: .iOS("15.0"),
            infoPlist: .extendingDefault(with: [
                "UILaunchScreen": .dictionary([:]),
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
                "UIBackgroundModes": .array([.string("remote-notification")]),
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
            dependencies: [
                .package(product: "RealmSwift"),
                .package(product: "FirebaseMessaging"),
                .target(name: "NewtroWidget"),
            ],
            settings: .settings(
                base: [
                    "DEVELOPMENT_TEAM": "48S4T8HCYX",
                ]
            )
        ),

        // MARK: - Widget Target
        .target(
            name: "NewtroWidget",
            destinations: .iOS,
            product: .appExtension,
            bundleId: "com.jun.NewTro-Todo.NewtroWidget",
            deploymentTargets: .iOS("15.0"),
            infoPlist: .extendingDefault(with: [
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
                "NewTro_Todo/Data/Storage/PostponeEventObject.swift",
                "NewTro_Todo/Data/Storage/WalletObject.swift",
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
                .package(product: "RealmSwift"),
            ],
            settings: .settings(
                base: [
                    "DEVELOPMENT_TEAM": "48S4T8HCYX",
                ]
            )
        ),

        // MARK: - UI Test Target
        .target(
            name: "NewTro_TodoUITests",
            destinations: .iOS,
            product: .uiTests,
            bundleId: "com.jun.NewTro-Todo.UITests",
            deploymentTargets: .iOS("15.0"),
            sources: ["NewTro_TodoUITests/**/*.swift"],
            dependencies: [
                .target(name: "NewTro_Todo"),
            ]
        ),
    ]
)
