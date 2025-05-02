import BusyTag
@preconcurrency import ORSSerial

@main
struct SwiftBusyTagSample {
  static func main() async throws {
    print(findVolume())
  }
}

private func findVolume(fileManager: FileManager = .default) -> URL? {
  print("Finding volume")
  for volume in fileManager.mountedVolumeURLs(
    includingResourceValuesForKeys: [.pathKey], options: .skipHiddenVolumes
  ) ?? [] {
    let readmeUrl = volume.appending(path: "readme.txt")
    guard let readme = try? String(contentsOf: readmeUrl, encoding: .utf8),
          readme.starts(with: "Local link: http://busytag") else { continue }
    return volume
  }
  return nil
}

private func colorSample() async throws {
  guard let port = try await BusyTag.findAny() else { return }
  do {
    try await BusyTag.set(color: randomColor(), using: port)
    print("Color set i think!")
  } catch {
    print("oh oh!")
    port.close()
  }
}

private func randomColor() -> String {
  (0..<3)
    .map { _ in
      if Bool.random() {
        UInt8.random(in: (.min)...(.max))
      } else {
        0
      }
    }
    .map { String(format: "%02x", $0) }
    .joined()
}
