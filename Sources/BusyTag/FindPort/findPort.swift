import ORSSerial
import Serial

extension BusyTag {
  public static func findPort() async throws -> ORSSerialPort? {
    for port in ORSSerialPortManager.shared().availablePorts {
      port.open()
      defer { port.close() }
      log("Checking port \(port.name)")
      let pong = try? await Identify().send(using: port)
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

struct Identify: AsciiCommand {
  typealias Response = String
  let request = "AT+GDN\r\n"
  let responseRegex = try! NSRegularExpression(pattern: #"\+DN:busytag-.*\r\n"#)
  let timeout: TimeInterval? = 1
}
