// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ShittyDesigns",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "ShittyDesigns",
            targets: ["ShittyDesigns"]),
    ],
    dependencies: [
        .package(url: "https://github.com/supabase-community/supabase-swift.git", from: "2.0.0"),
    ],
    targets: [
        .target(
            name: "ShittyDesigns",
            dependencies: [
                .product(name: "Supabase", package: "supabase-swift"),
            ]),
        .testTarget(
            name: "ShittyDesignsTests",
            dependencies: ["ShittyDesigns"]),
    ]
) 