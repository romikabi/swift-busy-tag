@preconcurrency import ORSSerial
@preconcurrency import Combine
@preconcurrency import Foundation

public actor ORSSerialDevice: Sendable, Device {
  private let delegate = Delegate()
  private var observation: NSKeyValueObservation?
  private var port: ORSSerialPort?

  public init(port: ORSSerialPort) {
    self.port = port
    self.port?.delegate = delegate
  }

  public init(
    pickPort: @escaping @Sendable (ORSSerialPortManager) async throws -> ORSSerialPort?,
    manager: ORSSerialPortManager = .shared()
  ) async {
    do {
      port = try await pickPort(manager)
      port?.delegate = delegate
    } catch {
      log("Couldn't pick port: \(error)")
    }
    self.observation = manager.observe(\.availablePorts, options: [.new]) { [weak self] manager, change in
      self?.portsChanged(pickPort: pickPort, manager: manager)
    }
  }

  private nonisolated func portsChanged(
    pickPort: @escaping @Sendable (ORSSerialPortManager) async throws -> ORSSerialPort?,
    manager: ORSSerialPortManager
  ) {
    Task {
      do {
        try await isolatedPortsChanged(pickPort: pickPort, manager: manager)
      } catch {
        log("Couldn't pick port: \(error)")
      }
    }
  }

  private func isolatedPortsChanged(
    pickPort: @escaping @Sendable (ORSSerialPortManager) async throws -> ORSSerialPort?,
    manager: ORSSerialPortManager
  ) async throws {
    if let port {
      if !manager.availablePorts.contains(port) {
        port.delegate = nil
        self.port = nil
      }
      return
    }
    port = try await pickPort(manager)
    port?.delegate = delegate
    log(#"picked \#(port?.path ?? "nil")"#)
  }

  private func setPort(_ port: ORSSerialPort) {
    self.port = port
  }

  deinit {
    port?.close()
  }

  public func send(
    _ string: some StringProtocol & Sendable,
    expecting regex: NSRegularExpression,
    timeout: TimeInterval? = 1
  ) async throws -> String {
    guard let port else { throw PortRemoved() }
    guard let requestData = string.data(using: .utf8) else {
      throw RequestToDataConversionFailed()
    }
    let request = ORSSerialRequest(
      dataToSend: requestData,
      userInfo: nil,
      timeoutInterval: timeout ?? -1,
      responseDescriptor: ORSSerialPacketDescriptor(
        regularExpression: regex,
        maximumPacketLength: .max,
        userInfo: nil
      )
    )
    var tokens = Set<AnyCancellable>()
    let responseData = try await withCheckedThrowingContinuation { continuation in
      delegate.serialPortDidReceiveResponseToRequest.first { _, _, respondedRequest in
        request == respondedRequest
      }.sink { _, data, _ in
        continuation.resume(returning: data)
      }.store(in: &tokens)

      delegate.serialPortRequestDidTimeout.first { _, timedOutRequest in
        request == timedOutRequest
      }.sink { _, _ in
        continuation.resume(throwing: RequestTimeout())
      }.store(in: &tokens)

      delegate.serialPortDidEncounterError.first().sink { _, error in
        continuation.resume(throwing: error)
      }.store(in: &tokens)

      delegate.serialPortWasRemovedFromSystem.first().sink { _ in
        continuation.resume(throwing: PortRemoved())
      }.store(in: &tokens)

      log(#"sending "\#(string)" to \#(port.path)"#)
      port.send(request)
    }
    guard let response = String(data: responseData, encoding: .utf8) else {
      throw ResponseToStringConversionFailed()
    }
    return response
  }

  nonisolated public func subscribe(expecting regex: NSRegularExpression) async throws -> any SendableAsyncSequence<String, Error> {
    guard let port = await port else { throw PortRemoved() }
    let descriptor = ORSSerialPacketDescriptor(regularExpression: regex, maximumPacketLength: .max, userInfo: nil)
    var tokens = Set<AnyCancellable>()
    return AsyncThrowingStream<String, Error> { [descriptor] continuation in
      delegate.serialPortDidReceivePacket.filter { _, _, receivingDescriptor in
        descriptor == receivingDescriptor
      }.sink { _, data, _ in
        guard let string = String(data: data, encoding: .utf8) else {
          continuation.finish(throwing: PacketToStringConversionFailed())
          return
        }
        continuation.yield(string)
      }.store(in: &tokens)

      delegate.serialPortWasRemovedFromSystem.first().sink { _ in
        continuation.finish(throwing: PortRemoved())
      }.store(in: &tokens)

      continuation.onTermination = { [weak port, tokens] _ in
        port?.stopListeningForPackets(matching: descriptor)
        _ = tokens
      }

      log(#"subscribing to "\#(regex.pattern)" on \#(port.path)"#)
      port.startListeningForPackets(matching: descriptor)
    }
  }

  public func open() async throws {
    guard let port else { throw PortRemoved() }
    guard !port.isOpen else { return }
    var tokens = Set<AnyCancellable>()
    try await withCheckedThrowingContinuation { continuation in
      delegate.serialPortWasOpened.first().sink { _ in
        continuation.resume()
      }.store(in: &tokens)
      delegate.serialPortDidEncounterError.first().sink { _, error in
        continuation.resume(throwing: error)
      }.store(in: &tokens)
      delegate.serialPortWasRemovedFromSystem.first().sink { _ in
        continuation.resume(throwing: PortRemoved())
      }.store(in: &tokens)
      log(#"opening \#(port.path)"#)
      port.open()
    }
  }

  public func close() async throws {
    guard let port else { throw PortRemoved() }
    guard port.isOpen else { return }
    var tokens = Set<AnyCancellable>()
    try await withCheckedThrowingContinuation { continuation in
      delegate.serialPortWasClosed.first().sink { _ in
        continuation.resume()
      }.store(in: &tokens)
      delegate.serialPortDidEncounterError.first().sink { _, error in
        continuation.resume(throwing: error)
      }.store(in: &tokens)
      delegate.serialPortWasRemovedFromSystem.first().sink { _ in
        continuation.resume(throwing: PortRemoved())
      }.store(in: &tokens)
      log(#"closing \#(port.path)"#)
      port.close()
    }
  }

  public func open<T: Sendable>(for operation: @Sendable () async throws -> T) async throws -> T {
    try await open()
    let result: T
    do {
      result = try await operation()
    } catch {
      try await close()
      throw error
    }
    try await close()
    return result
  }
}

public struct PortRemoved: Error {}
public struct RequestToDataConversionFailed: Error {}
public struct ResponseToStringConversionFailed: Error {}
public struct PacketToStringConversionFailed: Error {}
public struct RequestTimeout: Error {}
