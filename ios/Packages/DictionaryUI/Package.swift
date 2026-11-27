// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "DictionaryUI",
    defaultLocalization: "fr",
    platforms: [.iOS(.v26)],
    products: [
        .library(name: "DictionaryUI", targets: ["DictionaryUI"]),
    ],
    dependencies: [
        .package(path: "../DictionaryCore"),
    ],
    targets: [
        .target(
            name: "DictionaryUI",
            dependencies: ["DictionaryCore"],
            resources: [.process("Ressources")]
        ),
    ],
    swiftLanguageModes: [.v6]
)
