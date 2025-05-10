@preconcurrency import ORSSerial
import Serial

extension BusyTag {
  public convenience init() async {
    let device = await ORSSerialDevice { manager in
      for port in manager.availablePorts {
        let device = ORSSerialDevice(port: port)
        log("Checking port \(port.name)")

        let pong = try? await device.open {
          try? await device.send(
            "AT+GDN\r\n",
            expecting: try! NSRegularExpression(pattern: #"\+DN:busytag-.*\r\n"#),
            timeout: 1
          )
        }
        guard pong != nil else {
          log("Port \(port.name) isn't a match")
          continue
        }
        log("Port \(port.name) is a match")
        return port
      }
      return nil
    }
    self.init(device: device)
  }
}
