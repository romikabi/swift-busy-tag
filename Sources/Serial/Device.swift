import Foundation

public protocol Device: Sendable {
  func open() async throws

  func close() async throws

  func open<T: Sendable>(for operation: @Sendable () async throws -> T) async throws -> T

  func send(
    _ string: some StringProtocol & Sendable,
    expecting regex: NSRegularExpression,
    timeout: TimeInterval?
  ) async throws -> String

  func subscribe(
    expecting regex: NSRegularExpression
  ) async throws -> any SendableAsyncSequence<String, Error>
}
