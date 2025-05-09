import ORSSerial
import Serial
import SwiftUI

extension BusyTag {
  public func setImage(
    named name: some StringProtocol
  ) async throws {
    try await device.open {
      _ = try await device.send(
        "AT+SP=\(name)",
        expecting: try! NSRegularExpression(pattern: "OK\r\n"),
        timeout: 1
      )
    }
  }

  public func setImage(
    named name: some StringProtocol,
    fileManager: FileManager = .default,
    @ViewBuilder content: @Sendable () -> some View
  ) async throws {
    guard let volume = try await Self.findURL(fileManager: fileManager) else {
      throw NoVolume()
    }
    let url = volume.appending(path: name)

    try await device.open {
      async let writingDone: Void = writingDone()

      try await CGImage
        .make(content: content)
        .pngData
        .write(to: url)

      _ = try await writingDone

      try await setImage(named: name)
    }
  }

  private func writingDone() async throws {
    var expected = [
      "WIS,1",
      "WIS,0",
    ]
    for try await response in device.subscribe(expecting: try! NSRegularExpression(pattern: #"\+evn:.*\r\n"#)) {
      if let first = expected.first, response.contains(first) {
        expected.removeFirst()
      }
      if expected.isEmpty {
        break
      }
    }
  }
}

public struct NoVolume: Error {}
