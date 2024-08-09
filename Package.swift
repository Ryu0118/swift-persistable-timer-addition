// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-persistable-timer-addition",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .macCatalyst(.v13),
        .tvOS(.v13),
        .watchOS(.v6),
        .visionOS(.v1)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "PersistableTimerAddition",
            targets: ["PersistableTimerAddition"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/Ryu0118/swift-persistable-timer", exact: "0.4.0"),
        .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.2.1")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "PersistableTimerAddition",
            dependencies: [
                .product(name: "PersistableTimer", package: "swift-persistable-timer"),
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "DependenciesMacros", package: "swift-dependencies")
            ]
        ),
        .testTarget(
            name: "PersistableTimerAdditionTests",
            dependencies: ["PersistableTimerAddition"]
        ),
    ]
)
