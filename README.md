# swift-busy-tag

This is a library to control a [BusyTag](https://www.busy-tag.com/) device from Swift.

Features include:
[x] - Find the connected device
[x] - Find the path to the connected device in the file system 
[x] - Set the LED lining color
[x] - Set the display image

## Usage
```swift
import BusyTag
import SwiftUI

@main
struct Example {
  static func main() async throws {
    /// Find the connected device
    let busyTag = await BusyTag()

    /// Disable all LEDs
    try await busyTag.setColor(hex: "000000", to: .all)

    /// Set the color of the top LED to green
    try await busyTag.setColor(.green, to: .top)

    /// Set the color of the bottom LEDs to red
    try await busyTag.setColor(.red, to: [.bottomLeft, .bottomRight])

    /// Create a SwiftUI view, copy it over to the device and display it
    try await busyTag.setImage(named: "my-image.png") {
      Text("\(Date())")
        .font(.largeTitle)
        .frame(width: 240, height: 280)
        .background(Color.white)
    }
  }
}
```

# See also

* https://luxafor.helpscoutdocs.com/article/47-busy-tag-usb-cdc-command-reference-guide
