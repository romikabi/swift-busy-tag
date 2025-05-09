import SwiftUI

extension CGImage {
  public static func make(@ViewBuilder content: @Sendable () -> some View) async throws(NoCGImage) -> CGImage {
    try await isolatedCGImage(content: content)
  }
}

@MainActor
private func isolatedCGImage(@ViewBuilder content: () -> some View) throws(NoCGImage) -> CGImage {
  guard let image = ImageRenderer(content: content()).cgImage else { throw NoCGImage() }
  return image
}

public struct NoCGImage: Error {}
