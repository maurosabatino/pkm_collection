import ProjectDescription

let project = Project(
    name: "CoreKit",
    options: .options(disableSynthesizedResourceAccessors: false),
    targets: [
        .target(
            name: "CoreKit",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.maurosabatino.CoreKit",
            infoPlist: .default,
            sources: ["Sources/**"],
            resources: [],
            dependencies: [
                .external(name: "GRDB")
            ]
        ),
        .target(
            name: "CoreKitTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.maurosabatino.CoreKit.tests",
            infoPlist: .default,
            sources: ["Tests/**"],
            dependencies: [
                .target(name: "CoreKit")
            ]
        )
    ]
)
