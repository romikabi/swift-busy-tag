import ORSSerial

extension BusyTag {
  public static func setImage(
    path: String,
    using port: ORSSerialPort
  ) async throws {
    try await send(
      fire: SetImage(path: path),
      using: port
    )
  }
}
