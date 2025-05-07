import Foundation
import ORSSerial

struct Actions {
  var removedFromSystem: () -> Void
  var responseToRequest: (Data, ORSSerialRequest) -> Void
  var requestTimeout: (ORSSerialRequest) -> Void
}

final class Delegate: NSObject, ORSSerialPortDelegate {
  var actions: Actions?

  func serialPortWasRemovedFromSystem(_ serialPort: ORSSerialPort) {
    log("\(serialPort.path) removed from system")
    actions?.removedFromSystem()
  }

  func serialPort(_ serialPort: ORSSerialPort, didReceiveResponse responseData: Data, to request: ORSSerialRequest) {
    log(#"\#(serialPort.path) responded to request with "\#(format(responseData))""#)
    actions?.responseToRequest(responseData, request)
  }

  func serialPort(_ serialPort: ORSSerialPort, requestDidTimeout request: ORSSerialRequest) {
    log("\(serialPort.path) request timed out")
    actions?.requestTimeout(request)
  }

  // Just Logging

  func serialPort(_ serialPort: ORSSerialPort, didReceive data: Data) {
    log(#"\#(serialPort.path) received "\#(format(data))""#)
  }

  func serialPort(_ serialPort: ORSSerialPort, didEncounterError error: any Error) {
    log(#"\#(serialPort.path) encountered error "\#(error)""#)
  }

  func serialPortWasOpened(_ serialPort: ORSSerialPort) {
    log("\(serialPort.path) opened")
  }

  func serialPortWasClosed(_ serialPort: ORSSerialPort) {
    log("\(serialPort.path) closed")
  }
}
