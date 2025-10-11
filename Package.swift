// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SubnetCalculator",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "SubnetCalculator", targets: ["SubnetCalculator"])
    ],
    targets: [
        .target(
            name: "SubnetCalculatorCore",
            path: "Sources/SubnetCalculatorCore"
        ),
        .executableTarget(
            name: "SubnetCalculator",
            dependencies: ["SubnetCalculatorCore"],
            path: "Sources/SubnetCalculator",
            exclude: ["Models", "Networking"],
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "SubnetCalculatorTests",
            dependencies: ["SubnetCalculatorCore"],
            path: "Tests/SubnetCalculatorTests"
        )
    ]
)
