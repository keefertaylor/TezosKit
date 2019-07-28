// Copyright Keefer Taylor, 2019

import Foundation

// A representation of a pair parameter in micheline.
public struct MichelinePairParam: MichelineParam {
  public let networkRepresentation: [String: Any]

  public init(left: MichelineParam, right: MichelineParam) {
    let argArray = [ left.networkRepresentation, right.networkRepresentation ]
    self.networkRepresentation = [
      MichelineConstants.primitive: MichelineConstants.pair,
      MichelineConstants.args: argArray
    ]
  }
}
