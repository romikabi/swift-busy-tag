import Foundation
import ORSSerial

public protocol AsciiCommand<Response>: Command, AsciiFire {
  var request: String { get }
  var responseRegex: NSRegularExpression { get }
}

extension AsciiCommand {
  public var responseDescriptor: ORSSerialPacketDescriptor {
    ORSSerialPacketDescriptor(
      regularExpression: responseRegex,
      maximumPacketLength: .max,
      userInfo: nil
    )
  }
}

extension AsciiCommand where Response == String {
  public func convert(_ data: Data) throws(ConvertResponseToStringError) -> Response {
    guard let response = String(data: data, encoding: .ascii) else {
      throw ConvertResponseToStringError()
    }
    return response
  }
}
