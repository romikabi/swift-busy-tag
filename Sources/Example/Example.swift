import BusyTag
import SwiftUI

@main
struct Example {
  static func main() async throws {
    /// Find the connected device
    guard let busyTag = try await BusyTag() else { return }

    /// Disable all LEDs
    try await busyTag.setColor(hex: "000000", to: .all)

    /// Set the color of the top LED to green
    try await busyTag.setColor(.green, to: .top)

    /// Set the color of the bottom LEDs to red
    try await busyTag.setColor(.red, to: [.bottomLeft, .bottomRight])

    /// Set the image to `off.png`, which is stored on the device already
    try await busyTag.setImage(named: "off.png")

    /// Create a SwiftUI view, copy it over to the device and display it
    try await busyTag.setImage(named: "my-image.png") {
      Text("\(Date())")
        .font(.largeTitle)
        .frame(width: 240, height: 280)
        .background(Color.white)
    }
  }
}
