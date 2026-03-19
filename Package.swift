// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "CinemanaApp",
    platforms: [.iOS(.v16)],
    targets: [
        .target(
            name: "CinemanaApp",
            path: "."
        )
    ]
)