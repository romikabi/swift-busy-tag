import Foundation

struct SetImage: AsciiFire {
  init(path: String) {
    self.request = "AT+SP=\(path)"
  }

  let request: String
}
