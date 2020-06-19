// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "Mitra",
    platforms: [
        .iOS(.v12), .macOS(.v10_14),
    ],
    products: [
        .library(
            name: "Mitra",
            targets: ["Mitra"]),
    ],
    dependencies: [
        .package(url: "https://github.com/SergeBouts/XConcurrencyKit.git", from: "0.1.0"),
        .package(url: "https://github.com/SergeBouts/Mutexes.git", from: "0.1.0"),
    ],
    targets: [
        .target(
            name: "Mitra",
            dependencies: ["Mutexes"]),
        .testTarget(
            name: "MitraTests",
            dependencies: ["Mitra", "XConcurrencyKit"]),
    ]
)
