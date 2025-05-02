import Foundation
import ORSSerial

protocol Fire {
  var request: Data { get async throws }
}

protocol Command<Response>: Fire {
  associatedtype Response
  var responseDescriptor: ORSSerialPacketDescriptor { get }
  var timeout: TimeInterval? { get }
  func convert(_ data: Data) async throws -> Response
}

struct Match {
  let descriptor: ORSSerialPacketDescriptor
  let timeout: TimeInterval?
}
