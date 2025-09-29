import ProjectDescription

let project = Project(
    name: "PKMCollection",
    targets: [
        .target(
            name: "PKMCollection",
            destinations: .iOS,
            product: .app,
            bundleId: "com.maurosabatino.PKM-Collection",
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchScreen": [
                        "UIColorName": "",
                        "UIImageName": "",
                    ],
                ]
            ),
            resources: [
                .glob(pattern: "PKMCollection/Resources/**"),
            ],
            buildableFolders: [
                "PKMCollection/Sources",
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
            bundleId: "com.maurosabatino.PKM-CollectionTests",
            infoPlist: .default,
            buildableFolders: [
                "PKMCollection/Tests"
            ],
            dependencies: [.target(name: "PKMCollection")]
        ),
    ]
)
