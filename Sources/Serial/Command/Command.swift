import Foundation
import ORSSerial

public protocol Command<Response>: Fire {
  associatedtype Response
  var responseDescriptor: ORSSerialPacketDescriptor { get }
  var timeout: TimeInterval? { get }
  func convert(_ data: Data) async throws -> Response
}
