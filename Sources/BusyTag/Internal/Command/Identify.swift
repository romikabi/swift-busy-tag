import Foundation

struct Identify: AsciiCommand {
  typealias Response = String
  let request = "AT+GDN\r\n"
  let responseRegex = try! NSRegularExpression(pattern: #"\+DN:busytag-.*\r\n"#)
  let timeout: TimeInterval? = 1
}
