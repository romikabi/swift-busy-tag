// swift-tools-version: 6.0

import PackageDescription

let package = Package(
  name: "swift-busy-tag",
  platforms: [.macOS(.v13)],
  products: [
    .library(name: "BusyTag", targets: ["BusyTag"]),
    .library(name: "Serial", targets: ["Serial"]),
  ],
  dependencies: [
    .package(url: "https://github.com/armadsen/ORSSerialPort.git", from: "2.1.0"),
  ],
  targets: [
    .target(
      name: "Serial",
      dependencies: [
        .product(name: "ORSSerial", package: "ORSSerialPort"),
      ]),
    .target(
      name: "BusyTag",
      dependencies: [
        "Serial",
      ]),
  ]
)
