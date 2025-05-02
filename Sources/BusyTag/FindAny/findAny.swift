import ORSSerial

extension BusyTag {
  public static func findAny() async throws -> ORSSerialPort? {
    for port in ORSSerialPortManager.shared().availablePorts {
      port.open()
      defer { port.close() }
      let pong = try? await send(command: Identify(), using: port)
      guard pong != nil else { continue }
      return port
    }
    return nil
  }
}
