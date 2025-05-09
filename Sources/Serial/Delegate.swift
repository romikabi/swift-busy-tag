import ORSSerial
@preconcurrency import Combine

final class Delegate: NSObject, ORSSerialPortDelegate, Sendable {
  var serialPortWasRemovedFromSystem: some Publisher<ORSSerialPort, Never> {
    serialPortWasRemovedFromSystemSubject
  }
  private let serialPortWasRemovedFromSystemSubject = PassthroughSubject<ORSSerialPort, Never>()
  func serialPortWasRemovedFromSystem(_ serialPort: ORSSerialPort) {
    log("\(serialPort.path) removed from system")
    serialPortWasRemovedFromSystemSubject.send(serialPort)
  }

  var serialPortDidReceiveResponseToRequest: some Publisher<(ORSSerialPort, Data, ORSSerialRequest), Never> {
    serialPortDidReceiveResponseToRequestSubject
  }
  private let serialPortDidReceiveResponseToRequestSubject = PassthroughSubject<(ORSSerialPort, Data, ORSSerialRequest), Never>()
  func serialPort(_ serialPort: ORSSerialPort, didReceiveResponse responseData: Data, to request: ORSSerialRequest) {
    log(#"\#(serialPort.path) responded to request with "\#(format(responseData))""#)
    serialPortDidReceiveResponseToRequestSubject.send((serialPort, responseData, request))
  }

  var serialPortRequestDidTimeout: some Publisher<(ORSSerialPort, ORSSerialRequest), Never> {
    serialPortRequestDidTimeoutSubject
  }
  private let serialPortRequestDidTimeoutSubject = PassthroughSubject<(ORSSerialPort, ORSSerialRequest), Never>()
  func serialPort(_ serialPort: ORSSerialPort, requestDidTimeout request: ORSSerialRequest) {
    log("\(serialPort.path) request timed out")
    serialPortRequestDidTimeoutSubject.send((serialPort, request))
  }

  var serialPortDidReceiveData: some Publisher<(ORSSerialPort, Data), Never> {
    serialPortDidReceiveDataSubject
  }
  private let serialPortDidReceiveDataSubject = PassthroughSubject<(ORSSerialPort, Data), Never>()
  func serialPort(_ serialPort: ORSSerialPort, didReceive data: Data) {
    log(#"\#(serialPort.path) received "\#(format(data))""#)
    serialPortDidReceiveDataSubject.send((serialPort, data))
  }

  var serialPortDidEncounterError: some Publisher<(ORSSerialPort, Error), Never> {
    serialPortDidEncounterErrorSubject
  }
  private let serialPortDidEncounterErrorSubject = PassthroughSubject<(ORSSerialPort, Error), Never>()
  func serialPort(_ serialPort: ORSSerialPort, didEncounterError error: any Error) {
    log(#"\#(serialPort.path) encountered error "\#(error)""#)
    serialPortDidEncounterErrorSubject.send((serialPort, error))
  }

  var serialPortWasOpened: some Publisher<ORSSerialPort, Never> {
    serialPortWasOpenedSubject
  }
  private let serialPortWasOpenedSubject = PassthroughSubject<ORSSerialPort, Never>()
  func serialPortWasOpened(_ serialPort: ORSSerialPort) {
    log("\(serialPort.path) opened")
    serialPortWasOpenedSubject.send(serialPort)
  }

  var serialPortWasClosed: some Publisher<ORSSerialPort, Never> {
    serialPortWasClosedSubject
  }
  private let serialPortWasClosedSubject = PassthroughSubject<ORSSerialPort, Never>()
  func serialPortWasClosed(_ serialPort: ORSSerialPort) {
    log("\(serialPort.path) closed")
    serialPortWasClosedSubject.send(serialPort)
  }

  var serialPortDidReceivePacket: some Publisher<(ORSSerialPort, Data, ORSSerialPacketDescriptor), Never> {
    serialPortDidReceivePacketSubject
  }
  private let serialPortDidReceivePacketSubject = PassthroughSubject<(ORSSerialPort, Data, ORSSerialPacketDescriptor), Never>()
  func serialPort(_ serialPort: ORSSerialPort, didReceivePacket packetData: Data, matching descriptor: ORSSerialPacketDescriptor) {
    log(#"\#(serialPort.path) received packet "\#(format(packetData))" matching "\#(descriptor.regularExpression?.pattern ?? "?")""#)
    serialPortDidReceivePacketSubject.send((serialPort, packetData, descriptor))
  }
}
