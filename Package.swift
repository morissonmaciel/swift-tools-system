// swift-tools-version: 5.9

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "ToolsSystemMacros",
    platforms: [.macOS(.v14), .iOS(.v17)],
    products: [
        .library(
            name: "ToolsSystem",
            targets: ["ToolsSystem"]
        ),
        .library(
            name: "ToolsSystemMacros",
            targets: ["ToolsSystemMacros"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax.git", from: "509.0.0"),
    ],
    targets: [
        .macro(
            name: "ToolsSystemMacrosPlugin",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ]
        ),
        .target(
            name: "ToolsSystem"
        ),
        .target(
            name: "ToolsSystemMacros",
            dependencies: ["ToolsSystemMacrosPlugin", "ToolsSystem"]
        ),
        .testTarget(
            name: "ToolsSystemMacrosTests",
            dependencies: [
                "ToolsSystemMacros",
                "ToolsSystem",
            ]
        ),
    ]
)