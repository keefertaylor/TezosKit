// Copyright Keefer Taylor, 2019

import Foundation

// A representation of a pair parameter in micheline.
public struct MichelinePairParam: MichelineParam {
  public let json: [String: Any]

  public init(left: MichelineParam, right: MichelineParam) {
    let argArray = [ left.json, right.json ]
    self.json = [
      Micheline.primitive: Micheline.pair,
      Micheline.args: argArray
    ]
  }
}
