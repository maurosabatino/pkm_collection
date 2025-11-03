import ProjectDescription

let project = Project(
    name: "FeatureExpansion",
    options: .options(disableSynthesizedResourceAccessors: false),
    targets: [
        .target(
            name: "FeatureExpansion",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.maurosabatino.FeatureExpansion",
            infoPlist: .default,
            sources: ["Sources/**"],
            resources: ["Resources/**"],
            dependencies: [
                .project(target: "CoreKit", path: "../CoreKit"),
                .project(target: "UIComponents", path: "../UIComponents")
            ]
        ),
        .target(
            name: "FeatureExpansionTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.maurosabatino.FeatureExpansion.tests",
            infoPlist: .default,
            sources: ["Tests/**"],
            dependencies: [
                .target(name: "FeatureExpansion")
            ]
        )
    ]
)
