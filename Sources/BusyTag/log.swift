import Foundation

func log(_ message: @autoclosure () -> String) {
#if DEBUG
  print("[BusyTag][\(Date().formatted(date: .numeric, time: .standard))]: \(message())")
#endif
}
