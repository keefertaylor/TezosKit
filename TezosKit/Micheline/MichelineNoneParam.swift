// Copyright Keefer Taylor, 2019.

import Foundation

/// A representation of a none param in Micheline.
public struct MichelineNoneParam: MichelineParam {
  public let json: [String: Any] = [ Micheline.primitive: Micheline.none ]

  public init() {}
}
