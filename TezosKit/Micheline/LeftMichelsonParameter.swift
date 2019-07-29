// Copyright Keefer Taylor, 2019.

import Foundation

/// A representation of a left parameter in Michelson.
public class LeftMichelsonParameter: CustomMichelsonParameter {
  public init(arg: MichelsonParameter) {
    let argArray = [ arg.networkRepresentation ]
    super.init(networkRepresentation: [
      MichelineConstants.primitive: MichelineConstants.left,
      MichelineConstants.args: argArray
    ])
  }
}
