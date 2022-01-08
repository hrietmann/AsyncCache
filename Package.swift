// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AsyncCache",
    platforms: [
        .iOS(SupportedPlatform.IOSVersion.v13),
        .macOS(SupportedPlatform.MacOSVersion.v10_15)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "AsyncCache",
            targets: ["AsyncCache"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(name: "CodableKit", url: "https://github.com/hrietmann/CodableKit.git", from: "1.0.0") //.package(name: "CodableKit", path: "../CodableKit/")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "AsyncCache",
            dependencies: [
                .product(name: "CodableKit", package: "CodableKit")
            ]),
        .testTarget(
            name: "AsyncCacheTests",
            dependencies: ["AsyncCache"]),
    ]
)
