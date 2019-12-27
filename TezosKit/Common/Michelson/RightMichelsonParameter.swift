// Copyright Keefer Taylor, 2019.

import Foundation

// A representation of a right parameter in Michelson.
public class RightMichelsonParameter: AbstractMichelsonParameter {
  public init(arg: MichelsonParameter, annotations: [MichelsonAnnotation]? = nil) {
    let argArray = [ arg.networkRepresentation ]
    super.init(
      networkRepresentation: [
        MichelineConstants.primitive: MichelineConstants.right,
        MichelineConstants.args: argArray
      ],
      annotations: annotations
    )
  }
}
