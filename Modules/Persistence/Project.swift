import ProjectDescription

let project = Project(
    name: "Persistence",
    options: .options(disableSynthesizedResourceAccessors: false),
    targets: [
        .target(
            name: "Persistence",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.maurosabatino.Persistence",
            infoPlist: .default,
            sources: ["Sources/**"],
            resources: [],
            dependencies: [
                .project(target: "CoreModels", path: "../CoreModels"),
                .external(name: "GRDB")
            ]
        ),
        .target(
            name: "PersistenceTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.maurosabatino.Persistence.tests",
            infoPlist: .default,
            sources: ["Tests/**"],
            dependencies: [
                .target(name: "Persistence")
            ]
        )
    ]
)
