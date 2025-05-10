import Serial

public final class BusyTag: Sendable {
  public let device: Device

  public init(device: Device) {
    self.device = device
  }
}
