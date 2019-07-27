// Copyright Keefer Taylor, 2019.

import Foundation

/// A representation of an unit parameter in micheline.
public struct MichelineUnitParam: MichelineParam {
  public let json: [String: Any] = [
    "prim": "unit"
  ]

  public init() {}
}
