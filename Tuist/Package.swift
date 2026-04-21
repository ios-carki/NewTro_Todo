// swift-tools-version: 5.10
import PackageDescription

#if TUIST
import ProjectDescriptionHelpers
import ProjectDescription

let packageSettings = PackageSettings(
    productTypes: [
        "RealmSwift": .framework,
        "Realm": .framework,
    ],
    baseSettings: .settings(
        base: [
            "SWIFT_VERSION": "5.0",
        ]
    )
)
#endif

let package = Package(
    name: "PackageSettings",
    dependencies: []
)
