// Copyright Keefer Taylor, 2019.

import Foundation

/// A representation of a boolean parameter in micheline.
public struct MichelineBoolParam: MichelineParam {
  public let json: [String: Any]

  public init(bool: Bool) {
    let stringRep = bool ? Micheline.true : Micheline.false
    json = [ Micheline.primitive: stringRep ]
  }
}
