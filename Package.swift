// swift-tools-version:4.2
import PackageDescription

let package = Package(
    name: "TezosKit",
    products: [
        .library(
            name: "TezosKit",
            targets: ["TezosKit"]),
    ],
    dependencies: [
		.package(url: "https://github.com/jedisct1/swift-sodium.git", .branch("master") ),
		.package(url: "https://github.com/keefertaylor/CKMnemonic.git", .branch("master")),
		.package(url: "https://github.com/cloutiertyler/Base58String.git", from: "0.1.0")
    ],
    targets: [
        .target(
            name: "TezosKit",
            dependencies: ["Sodium", "CKMnemonic", "Base58String"],
            path: "Sources"),
    ]
)
