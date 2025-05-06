import ORSSerial

extension BusyTag {
  public static func findPort() async throws -> ORSSerialPort? {
    for port in ORSSerialPortManager.shared().availablePorts {
      port.open()
      defer { port.close() }
      log("Checking port \(port.name)")
      let pong = try? await send(command: Identify(), using: port)
      guard pong != nil else {
        log("Port \(port.name) not isn't a match")
        continue
      }
      log("Port \(port.name) is a match")
      return port
    }
    return nil
  }
}
