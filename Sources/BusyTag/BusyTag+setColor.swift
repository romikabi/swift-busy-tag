import Foundation
import AppKit
import SwiftUI

extension BusyTag {
  public func setColor(hex: some StringProtocol & Sendable, to led: LED) async throws {
    try await device.open {
      _ = try await device.send(
        "AT+SC=\(led.rawValue),\(hex.trimmingCharacters(in: ["#"]))",
        expecting: try! NSRegularExpression(pattern: "OK\r\n"),
        timeout: 1
      )
    }
  }

  public func setColor(_ color: Color, to led: LED) async throws {
    try await setColor(hex: color.hex, to: led)
  }
}

extension Color {
  fileprivate var hex: some StringProtocol & Sendable {
    let color = NSColor(self)
    let rgb = color.usingColorSpace(.deviceRGB) ?? color
    let red = Int(rgb.redComponent * 255)
    let green = Int(rgb.greenComponent * 255)
    let blue = Int(rgb.blueComponent * 255)
    return String(format: "%02X%02X%02X", red, green, blue)
  }
}
