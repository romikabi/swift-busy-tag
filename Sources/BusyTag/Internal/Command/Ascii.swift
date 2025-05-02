import Foundation
import ORSSerial

protocol AsciiFire: Fire {
  var request: String { get }
}

extension AsciiFire {
  var request: Data {
    get throws {
      guard let request = request.data(using: .ascii) else {
        throw AsciiCommandError.cantConvertRequestToData
      }
      return request
    }
  }
}

protocol AsciiCommand<Response>: Command, AsciiFire {
  var request: String { get }
  var responseRegex: NSRegularExpression { get }
}

extension AsciiCommand {
  var responseDescriptor: ORSSerialPacketDescriptor {
    return ORSSerialPacketDescriptor(
      regularExpression: responseRegex,
      maximumPacketLength: .max,
      userInfo: nil
    )
  }
}

extension AsciiCommand where Response == String {
  func convert(_ data: Data) throws -> Response {
    guard let response = String(data: data, encoding: .ascii) else {
      throw AsciiCommandError.cantConvertResponseToString
    }
    return response
  }
}

enum AsciiCommandError: Error {
  case cantConvertRequestToData
  case cantConvertResponseToString
}
