// swift-tools-version: 6.1

import PackageDescription

let package = Package(
    name: "ConlangModels",
    platforms: [.macOS(.v15), .iOS(.v18)],
    products: [
        .library(
            name: "ConlangModels",
            targets: ["ConlangModels"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/SimplyDanny/SwiftLintPlugins", from: "0.59.1"),
    ],
    targets: [
        .target(
            name: "ConlangModels",
            plugins: [
                .plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins")
            ]
        ),
        .testTarget(
            name: "ConlangModelsTests",
            dependencies: ["ConlangModels"],
            plugins: [
                .plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins")
            ]
        )
    ]
)
