import Foundation

public protocol Fire {
  var request: Data { get async throws }
}
