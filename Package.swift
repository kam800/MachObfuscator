// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MachObfuscator",
    platforms: [
        .macOS(.v10_13)
    ],
    products: [
        .executable(
            name: "MachObfuscator",
            targets: ["Run"]
        ),
    ],
    targets: [
        .target(
            name: "Run",
            dependencies: ["App"]
        ),
        .target(
            name: "App"
        ),
        .testTarget(
            name: "AppTests",
            dependencies: ["App"],
            exclude: [
                "SampleAppSources",
                "NibTests/SamplesSource"
            ],
            resources: [
                .copy("HeaderParsingTests/Samples/CraftedFramework.framework"),
                .copy("HeaderParsingTests/Samples/LibrarySourceCode.bundle"),
                .copy("HeaderParsingTests/Samples/SystemLikeFramework.framework"),
                .copy("MachTests/Samples/SampleFatIosExecutable"),
                .copy("MachTests/Samples/SampleMachoIos12_0Executable"),
                .copy("MachTests/Samples/SampleMachoMac10_14Executable"),
                .copy("MachTests/Samples/SampleMachoMacExecutable"),
            ]
        )
    ]
)
