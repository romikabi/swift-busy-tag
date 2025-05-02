// swift-tools-version: 6.0

import PackageDescription

let package = Package(
  name: "swift-busy-tag",
  products: [
    .library(
      name: "swift-busy-tag",
      targets: ["swift-busy-tag"]
    ),
  ],
  dependencies: [
    .package(url: "https://github.com/mredig/SwiftSerial.git", from: "0.1.5"),
  ],
  targets: [
    .target(name: "swift-busy-tag"),
    .testTarget(
      name: "swift-busy-tag-tests",
      dependencies: ["swift-busy-tag"]
    ),
  ]
)
