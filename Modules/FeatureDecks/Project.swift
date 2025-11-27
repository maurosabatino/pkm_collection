import ProjectDescription

let project = Project(
    name: "FeatureDecks",
    options: .options(disableSynthesizedResourceAccessors: false),
    targets: [
        .target(
            name: "FeatureDecks",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.maurosabatino.FeatureDecks",
            infoPlist: .default,
            sources: ["Sources/**"],
            resources: [],
            dependencies: [
                .project(target: "CoreKit", path: "../CoreKit"),
                .project(target: "CoreModels", path: "../CoreModels"),
                .project(target: "Persistence", path: "../Persistence"),
                .project(target: "UIComponents", path: "../UIComponents")
            ]
        ),
        .target(
            name: "FeatureDecksTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.maurosabatino.FeatureDecks.tests",
            infoPlist: .default,
            sources: ["Tests/**"],
            dependencies: [
                .target(name: "FeatureDecks")
            ]
        )
    ]
)
