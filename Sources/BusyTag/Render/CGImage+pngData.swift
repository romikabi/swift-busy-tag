import SwiftUI

extension CGImage {
  var pngData: Data {
    get throws(NoPNGRepresentation) {
      let rep = NSBitmapImageRep(cgImage: self)
      guard let pngData = rep.representation(using: .png, properties: [:]) else {
        throw NoPNGRepresentation()
      }
      return pngData
    }
  }
}

public struct NoPNGRepresentation: Error {}

