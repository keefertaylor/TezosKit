// Copyright Keefer Taylor, 2019.

import Foundation

/// A representation of a boolean parameter in Michelson.
public class BoolMichelsonParameter: AbstractMichelsonParameter {
  public init(bool: Bool) {
    let stringRep = bool ? MichelineConstants.true : MichelineConstants.false
    super.init(networkRepresentation: [MichelineConstants.primitive: stringRep ])
  }
}
