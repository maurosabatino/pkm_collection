import ProjectDescription

let project = Project(
    name: "CoreModels",
    targets: [
        .target(
            name: "CoreModels",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.maurosabatino.CoreModels",
            infoPlist: .default,
            sources: ["Sources/**"],
            resources: []
        )
    ]
)
