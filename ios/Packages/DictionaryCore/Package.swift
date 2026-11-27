// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "DictionaryCore",
    defaultLocalization: "fr",
    platforms: [.iOS(.v26), .macOS(.v14)],
    products: [
        .library(name: "DictionaryCore", targets: ["DictionaryCore"]),
    ],
    targets: [
        .target(name: "DictionaryCore"),
        .testTarget(
            name: "DictionaryCoreTests",
            dependencies: ["DictionaryCore"],
            resources: [.copy("Ressources")]
        ),
    ],
    swiftLanguageModes: [.v6]
)
