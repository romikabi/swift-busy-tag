// swift-tools-version: 6.0

import PackageDescription

let package = Package(
  name: "swift-busy-tag",
  platforms: [.macOS(.v13)],
  products: [
    .library(
      name: "BusyTag",
      targets: ["BusyTag"]
    ),
  ],
  dependencies: [
//    .package(url: "https://github.com/christophhagen/SwiftSerial.git", from: "1.1.0"),
    .package(url: "https://github.com/armadsen/ORSSerialPort.git", from: "2.1.0"),
  ],
  targets: [
    .target(
      name: "BusyTag",
      dependencies: [
//        .byName(name: "SwiftSerial"),
        .product(name: "ORSSerial", package: "ORSSerialPort"),
      ]),
    .testTarget(
      name: "BusyTagTests",
      dependencies: ["BusyTag"]
    ),
    .executableTarget(
      name: "BusyTagSample",
      dependencies: [
        "BusyTag",
      ]
    ),
  ]
)
