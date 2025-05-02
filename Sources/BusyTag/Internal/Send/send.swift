import ORSSerial

extension BusyTag {
  static func send(
    fire: Fire,
    using port: ORSSerialPort
  ) async throws {
    port.open()
    defer { port.close() }

    let data = try await fire.request
    log(#"sending "\#(format(data))" to \#(port.path)"#)
    port.send(data)
  }

  static func send<C: Command>(
    command: C,
    using port: ORSSerialPort
  ) async throws -> C.Response {
    port.open()
    defer { port.close() }

    let data = try await send(
      command.request,
      using: port,
      timeout: command.timeout,
      responseDescriptor: command.responseDescriptor
    )
    return try await command.convert(data)
  }

  private static func send(
    _ data: Data,
    using port: ORSSerialPort,
    timeout: TimeInterval?,
    responseDescriptor: ORSSerialPacketDescriptor?
  ) async throws -> Data {
    let request = ORSSerialRequest(
      dataToSend: data,
      userInfo: nil,
      timeoutInterval: timeout ?? -1,
      responseDescriptor: responseDescriptor
    )
    
    let delegate = Delegate()
    let oldDelegate = port.delegate
    defer { port.delegate = oldDelegate }
    port.delegate = delegate
    
    return try await withCheckedThrowingContinuation { continuation in
      delegate.actions = Actions(
        removedFromSystem: {
          continuation.resume(throwing: SendError.portRemoved)
        },
        responseToRequest: { data, request in
          continuation.resume(returning: data)
        },
        requestTimeout: { request in
          continuation.resume(throwing: SendError.requestTimeout)
        }
      )
      log(#"sending "\#(format(data))" to \#(port.path)"#)
      port.send(request)
    }
  }
}
