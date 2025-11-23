import ProjectDescription

let project = Project(
    name: "UIComponents",
    options: .options(disableSynthesizedResourceAccessors: false),
    targets: [
        .target(
            name: "UIComponents",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.maurosabatino.UIComponents",
            infoPlist: .default,
            sources: ["Sources/**"],
            resources: ["Resources/**"],
            dependencies: [
                .project(target: "CoreKit", path: "../CoreKit"),
                .external(name: "Kingfisher")
            ]
        ),
        .target(
            name: "UIComponentsTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.maurosabatino.UIComponents.tests",
            infoPlist: .default,
            sources: ["Tests/**"],
            dependencies: [
                .target(name: "UIComponents")
            ]
        )
    ]
)
