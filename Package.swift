// swift-tools-version: 6.2
// the usage pieces usaaage and swaaap share, so both read as one family: the window meter, the
// plan badge, the status dot, the in use treatment, the refresh button, the account row and card,
// the formats and the menu bar glyph. built only from the kit's tokens (LaaabsKit, pinned at the
// revision both apps use). view values only: each app maps its own model into them.
import PackageDescription

let package = Package(
    name: "UsaaageKit",
    platforms: [.macOS("27.0")],
    products: [
        .library(name: "UsaaageKit", targets: ["UsaaageKit"]),
    ],
    dependencies: [
        // the same revision as usaaage's and swaaap's project.yml; bump all three together.
        .package(url: "https://github.com/bylaaabs/ui-swift", revision: "094de0f9ecd14c28edd3ccd9f44d7dd14246146f"),
    ],
    targets: [
        .target(
            name: "UsaaageKit",
            dependencies: [.product(name: "LaaabsKit", package: "ui-swift")],
            resources: [.copy("Resources/clients")],
            swiftSettings: [.swiftLanguageMode(.v6)]
        ),
        .testTarget(
            name: "UsaaageKitTests",
            dependencies: ["UsaaageKit", .product(name: "LaaabsKit", package: "ui-swift")]
        ),
    ]
)
