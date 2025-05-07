import ORSSerial
import Serial

extension BusyTag {
  public static func setImage(
    path: String,
    using port: ORSSerialPort
  ) async throws {
    try await SetImage(path: path).fire(using: port)
  }
}

struct SetImage: AsciiFire {
  init(path: String) {
    self.request = "AT+SP=\(path)"
  }

  let request: String
}
