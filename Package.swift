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
        .package(url: "https://github.com/SerhiyButz/XConcurrencyKit.git", from: "0.2.0"),
        .package(url: "https://github.com/SerhiyButz/Mutexes.git", from: "0.2.0"),
        .package(url: "https://github.com/apple/swift-atomics", from: "1.0.2"),
    ],
    targets: [
        .target(
            name: "Mitra",
            dependencies: ["Mutexes", .product(name: "Atomics", package: "swift-atomics")]),
        .testTarget(
            name: "MitraTests",
            dependencies: ["Mitra", "XConcurrencyKit"]),
    ]
)
