import Foundation

public protocol AsciiFire: Fire {
  var request: String { get }
}

extension AsciiFire {
  public var request: Data {
    get throws(ConvertRequestToDataError) {
      guard let request = request.data(using: .ascii) else {
        throw ConvertRequestToDataError()
      }
      return request
    }
  }
}
