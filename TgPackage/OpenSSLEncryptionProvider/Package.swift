// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription


let package = Package(
    name: "OpenSSLEncryption",
    platforms: [
        .macOS(.v10_13)
    ],
    products: [
        .library(
            name: "OpenSSLEncryption",
            targets: ["OpenSSLEncryption"]),
    ],
    dependencies: [
        .package(name: "OpenSSL", path: "../third-party/OpenSSL"),
    ],
    targets: [
        .target(
            name: "OpenSSLEncryption",
            dependencies: [
                .product(name: "OpenSSL", package: "OpenSSL")
            ],
            path: ".",
            exclude: ["BUILD"],
            publicHeadersPath: "PublicHeaders",
            cSettings: [
                .headerSearchPath("PublicHeaders"),
                .unsafeFlags([
                    "-I../EncryptionProvider/PublicHeaders"
                ])
            ]),
    ]
)
