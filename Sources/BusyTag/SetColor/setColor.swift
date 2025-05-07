import ORSSerial
import Serial

extension BusyTag {
  public static func setColor(
    _ color: String,
    using port: ORSSerialPort
  ) async throws {
    try await SetColor(color: color).fire(using: port)
  }
}

struct SetColor: AsciiFire {
  init(color: String) {
    let color = color.trimmingCharacters(in: ["#"])
    self.request = "AT+SC=\(127),\(color))"
  }

  let request: String
}
