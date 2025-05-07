import ORSSerial

extension BusyTag {
  public static func setColor(
    _ color: String,
    using port: ORSSerialPort
  ) async throws {
    try await send(
      fire: SetColor(color: color),
      using: port
    )
  }
}
