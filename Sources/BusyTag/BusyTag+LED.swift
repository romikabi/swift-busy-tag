//
//  BusyTag+LED.swift
//  swift-busy-tag
//
//  Created by Roman Abuziarov on 2025-05-08.
//

extension BusyTag {
  public struct LED: OptionSet, Sendable {
    public let rawValue: UInt8
    public init(rawValue: UInt8) {
      self.rawValue = rawValue
    }

    public static let bottomLeft = LED(rawValue: 0b00000001)
    public static let middleLeft = LED(rawValue: 0b00000010)
    public static let topLeft = LED(rawValue: 0b00000100)
    public static let top = LED(rawValue: 0b00001000)
    public static let topRight = LED(rawValue: 0b00010000)
    public static let middleRight = LED(rawValue: 0b00100000)
    public static let bottomRight = LED(rawValue: 0b01000000)
    public static let all = LED(rawValue: 0b01111111)
  }
}
