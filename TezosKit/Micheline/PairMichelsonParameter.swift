// Copyright Keefer Taylor, 2019

import Foundation

// A representation of a pair parameter in Michelson.
public class PairMichelsonParameter: CustomMichelsonParameter {
  public init(left: MichelsonParameter, right: MichelsonParameter) {
    let argArray = [ left.networkRepresentation, right.networkRepresentation ]
    super.init(
      networkRepresentation: [
        MichelineConstants.primitive: MichelineConstants.pair,
        MichelineConstants.args: argArray
      ]
    )
  }
}
