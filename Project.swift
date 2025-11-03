import ProjectDescription

let project = Project(
    name: "PKMCollection",
    options: .options(
        automaticSchemesOptions: .enabled(), 
        disableSynthesizedResourceAccessors: false
    ),
    targets: [

        // MARK: App
        .target(
            name: "PKMCollection",
            destinations: [.iPhone, .iPad], 
            product: .app,
            bundleId: "com.maurosabatino.pkmcollection",
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchScreen": [
                        "UIColorName": "",
                        "UIImageName": ""
                    ]
                ]
            ),
            sources: [
                "App/Sources/**"
            ],
            resources: [
                "App/Resources/**"
            ],
            dependencies: [
                // Internal
                .project(target: "FeatureExpansion", path: "Modules/FeatureExpansion"),
                .project(target: "UIComponents", path: "Modules/UIComponents"),
                .project(target: "CoreKit", path: "Modules/CoreKit"),

                // External
                .external(name: "Kingfisher"),
                .external(name: "FirebaseAnalytics")
            ],
            settings: .settings(
                base: [
                    "ASSETCATALOG_COMPILER_GENERATE_ASSET_SYMBOLS": "YES",
                    "ENABLE_USER_SCRIPT_SANDBOXING": "YES",
                    "STRING_CATALOG_GENERATE_SYMBOLS": "YES"
                ]
            )
        ),

        // MARK: Unit Tests
        .target(
            name: "PKMCollectionTests",
            destinations: [.iPhone],
            product: .unitTests,
            bundleId: "com.maurosabatino.pkmcollection.tests",
            infoPlist: .default,
            sources: ["Tests/Unit/**"],
            dependencies: [
                .target(name: "PKMCollection")
            ]
        ),

        // MARK: UI Tests
        .target(
            name: "PKMCollectionUITests",
            destinations: [.iPhone],
            product: .uiTests,
            bundleId: "com.maurosabatino.pkmcollection.uitests",
            infoPlist: .default,
            sources: ["Tests/UITests/**"],
            dependencies: [
                .target(name: "PKMCollection")
            ]
        )
    ]
)
