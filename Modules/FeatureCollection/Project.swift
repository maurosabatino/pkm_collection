import ProjectDescription

let project = Project(
    name: "FeatureCollection",
    options: .options(disableSynthesizedResourceAccessors: false),
    targets: [
        .target(
            name: "FeatureCollection",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.maurosabatino.FeatureCollection",
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
            name: "FeatureCollectionTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.maurosabatino.FeatureCollection.tests",
            infoPlist: .default,
            sources: ["Tests/**"],
            dependencies: [
                .target(name: "FeatureCollection")
            ]
        )
    ]
)
