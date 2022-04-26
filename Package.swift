// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Pelican",
    platforms: [.iOS(.v13),
                .watchOS(.v6),
                .macOS(.v12),
                .tvOS(.v13)],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "PelicanProtocols",
            targets: ["PelicanProtocols"]),
        .library(
            name: "PelicanRepositories",
            targets: ["PelicanRepositories"]),
        .library(
            name: "PelicanKeychain",
            targets: ["PelicanKeychain"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "PelicanProtocols",
            dependencies: [],
            path: "Sources/Protocols"),
        .testTarget(
            name: "PelicanProtocolsTests",
            dependencies: ["PelicanProtocols"],
            path: "Tests/Protocols"),
        .target(
            name: "PelicanRepositories",
            dependencies: ["PelicanProtocols"],
            path: "Sources/Repositories"),
        .testTarget(
            name: "PelicanRepositoriesTests",
            dependencies: ["PelicanProtocols", "PelicanRepositories"],
            path: "Tests/Repositories"),
        .target(
            name: "PelicanKeychain",
            dependencies: ["PelicanProtocols"],
            path: "Sources/Keychain"),
        .testTarget(
            name: "PelicanKeychainTests",
            dependencies: ["PelicanProtocols", "PelicanKeychain"],
            path: "Tests/Keychain"),
    ]
)
