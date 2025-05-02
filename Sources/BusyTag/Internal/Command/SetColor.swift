import Foundation

struct SetColor: AsciiFire {
  init(color: String) {
    let color = color.trimmingCharacters(in: ["#"])
    self.request = "AT+SC=\(127),\(color))"
  }

  let request: String
}
