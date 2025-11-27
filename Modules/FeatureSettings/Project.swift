import ProjectDescription

let project = Project(
    name: "FeatureSettings",
    options: .options(disableSynthesizedResourceAccessors: false),
    targets: [
        .target(
            name: "FeatureSettings",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.maurosabatino.FeatureSettings",
            infoPlist: .default,
            sources: ["Sources/**"],
            resources: [],
            dependencies: [
                .project(target: "CoreKit", path: "../CoreKit")
            ]
        )
    ]
)
