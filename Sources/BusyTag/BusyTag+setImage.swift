import ORSSerial
import Serial
import SwiftUI

extension BusyTag {
  public func setImage(
    named name: some StringProtocol & Sendable
  ) async throws {
    try await device.open {
      _ = try await device.send(
        "AT+SP=\(name)",
        expecting: try! NSRegularExpression(pattern: "OK\r\n"),
        timeout: 1
      )
    }
  }

  public func setImage(
    named name: some StringProtocol & Sendable,
    fileManager: FileManager = .default,
    @ViewBuilder content: @Sendable () -> some View
  ) async throws {
    guard let volume = try await Self.findURL(fileManager: fileManager) else {
      throw NoVolume()
    }
    let url = volume.appending(path: name)

    try await device.open {
      async let writingDone: Void = writingDone()

      try await CGImage
        .make(content: content)
        .pngData
        .write(to: url)

      _ = try await writingDone

      try await setImage(named: name)
    }
  }

  private func writingDone() async throws {
    try await WriteWaiter().wait(
      try await device.subscribe(expecting: try! NSRegularExpression(pattern: #"\+evn:.*\r\n"#))
    )
  }
}

public struct NoVolume: Error {}

private actor WriteWaiter {
  init() {
    (events, continuation) = AsyncStream.makeStream()
  }

  func wait(_ events: some SendableAsyncSequence<String, Error>) async throws {
    async let _ = readoutEvents(events)
    for await _ in self.events {
      if checkCompleteness() {
        break
      }
    }
  }

  private func readoutEvents(_ events: some AsyncSequence<String, Error>) async throws {
    for try await response in events {
      if response.contains(writingStart) {
        writingStarted = true
      }
      if response.contains(writingEnd), writingStarted {
        writingEnded = true
      }
      if response.contains(patternStart) {
        patternStarted = true
      }
      if response.contains(patternEnd), patternStarted {
        patternEnded = true
      }
      continuation.yield()
    }
  }

  private func checkCompleteness() -> Bool {
    log("W1 \(writingStarted) W0 \(writingEnded) P1 \(patternStarted) P0 \(patternEnded) ⏰ \(waitedForPattern)")
    if writingStarted, writingEnded, patternStarted, patternEnded {
      return true
    }

    if writingStarted, writingEnded, patternStarted, patternEnded {
      return true
    }

    if writingStarted, writingEnded, !patternEnded, !patternEnded, waitedForPattern {
      return true
    }

    if writingStarted, writingEnded, !patternStarted, !patternEnded, !waitedForPattern {
      Task {
        try await Task.sleep(for: .seconds(3))
        waitedForPattern = true
        continuation.yield()
      }
    }

    return false
  }

  private let events: AsyncStream<Void>
  private let continuation: AsyncStream<Void>.Continuation

  private var writingStarted = false
  private var writingEnded = false
  private var patternStarted = false
  private var patternEnded = false
  private var waitedForPattern = false

  private let writingStart = "WIS,1"
  private let writingEnd = "WIS,0"
  private let patternStart = "PP,1"
  private let patternEnd = "PP,0"
}
