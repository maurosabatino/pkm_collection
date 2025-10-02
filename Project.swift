import ProjectDescription

let project = Project(
    name: "PKMCollection",
    targets: [
        .target(
            name: "PKMCollection",
            destinations: .iOS,
            product: .app,
            bundleId: "com.maurosabatino.pkmcollection",
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchScreen": [
                        "UIColorName": "",
                        "UIImageName": "",
                    ],
                ]
            ),
            sources: [
                "App/Sources/**",
                "Modules/**",
            ],
            resources: [
                .glob(pattern: "App/Resources/**"),
            ],
            dependencies: [
                .external(name: "Kingfisher"),
                .external(name: "FirebaseAnalytics"),
            ],
            settings: .settings(
                base: [
                    "ASSETCATALOG_COMPILER_GENERATE_ASSET_SYMBOLS": "YES",
                    "ENABLE_USER_SCRIPT_SANDBOXING": "YES",
                    "STRING_CATALOG_GENERATE_SYMBOLS": "YES",
                ]
            )
        ),
        .target(
            name: "PKMCollectionTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.maurosabatino.pkmcollection.tests",
            infoPlist: .default,
            sources: ["Tests/Unit/**"],
            dependencies: [
                .target(name: "PKMCollection"),
            ]
        ),
        .target(
            name: "PKMCollectionUITests",
            destinations: .iOS,
            product: .uiTests,
            bundleId: "com.maurosabatino.pkmcollection.uitests",
            infoPlist: .default,
            sources: ["Tests/UITests/**"],
            dependencies: [
                .target(name: "PKMCollection"),
            ]
        )
    ]
)
