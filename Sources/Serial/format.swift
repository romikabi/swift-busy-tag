import Foundation

func format(_ data: Data) -> String {
  let string = String(data: data, encoding: .ascii)
  return string?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "nil"
}
