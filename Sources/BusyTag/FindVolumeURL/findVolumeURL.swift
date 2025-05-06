import ORSSerial

extension BusyTag {
  public static func findVolumeURL(
    path: some StringProtocol = "readme.txt",
    contains regex: some RegexComponent = /Local link: http:\/\/busytag/,
    fileManager: FileManager = .default
  ) -> URL? {
    log("Looking for volume by matching \(regex) in \(path)")
    for volume in fileManager.mountedVolumeURLs(
      includingResourceValuesForKeys: [.pathKey], options: .skipHiddenVolumes
    ) ?? [] {
      log("Checking volume \(volume)")
      let path = volume.appending(path: path)
      guard let file = try? String(contentsOf: path, encoding: .utf8) else {
        log("File not found at \(path)")
        continue
      }
      guard file.contains(regex) else {
        log("File does not contain \(regex)")
        continue
      }
      log("Found volume at \(volume)")
      return volume
    }
    return nil
  }
}
