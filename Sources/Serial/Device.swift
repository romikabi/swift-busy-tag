import Foundation

public protocol Device: Sendable {
  func open() async throws

  func close() async throws

  func open<T>(for operation: () async throws -> T) async throws -> T

  func send(
    _ string: some StringProtocol,
    expecting regex: NSRegularExpression,
    timeout: TimeInterval?
  ) async throws -> String

  func subscribe(
    expecting regex: NSRegularExpression
  ) -> any AsyncSequence<String, Error>
}
