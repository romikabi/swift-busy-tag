import ORSSerial

extension Fire {
  public func fire(using port: ORSSerialPort) async throws {
    port.open()
    defer { port.close() }

    let data = try await request
    log(#"sending "\#(format(data))" to \#(port.path)"#)
    port.send(data)
  }
}

extension Command {
  public func send(using port: ORSSerialPort) async throws -> Response {
    port.open()
    defer { port.close() }

    let data = try await Serial.send(
      request,
      using: port,
      timeout: timeout,
      responseDescriptor: responseDescriptor
    )
    return try await convert(data)
  }
}

private func send(
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
