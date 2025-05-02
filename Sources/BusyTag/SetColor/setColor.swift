import ORSSerial

extension BusyTag {
  public static func set(
    color: String,
    using port: ORSSerialPort
  ) async throws {
    _ = try await send(
      fire: SetColor(color: color),
      using: port
    )
  }
}
