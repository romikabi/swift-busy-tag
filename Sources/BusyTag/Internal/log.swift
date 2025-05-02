import Foundation

func log(_ message: @autoclosure () -> String) {
#if DEBUG
  print("[swift-busy-tag][\(Date().formatted(date: .numeric, time: .standard))]: \(message())")
#endif
}
