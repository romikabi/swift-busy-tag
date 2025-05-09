import Serial

public final class BusyTag: Sendable {
  let device: Device
  init(device: Device) {
    self.device = device
  }
}
