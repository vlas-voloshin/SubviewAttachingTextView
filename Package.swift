// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "SubviewAttachingTextView",
    platforms: [.iOS(.v8), .tvOS(.v9)],
    products: [
        .library(
            name: "SubviewAttachingTextView",
            targets: ["SubviewAttachingTextView"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "SubviewAttachingTextView",
            dependencies: [],
            path: "SubviewAttachingTextView"
        )
    ],
    swiftLanguageVersions: [.v5]
)
