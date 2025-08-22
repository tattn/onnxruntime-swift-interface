// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "onnxruntime-swift-interface",
    products: [
        .library(
            name: "onnxruntime-swift-interface",
            targets: ["onnxruntime-swift-interface"]),
    ],
    targets: [
        .target(
            name: "onnxruntime-swift-interface",
            swiftSettings: [
                .interoperabilityMode(.Cxx)
            ]
        ),
    ],
    cxxLanguageStandard: .cxx20
)
