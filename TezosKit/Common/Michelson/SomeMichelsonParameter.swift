// Copyright Keefer Taylor, 2019.

import Foundation

// A representation of a some parameter in Michelson.
public class SomeMichelsonParameter: AbstractMichelsonParameter {
  public init(some: MichelsonParameter, annotations: [MichelsonAnnotation]? = nil) {
    super.init(
      networkRepresentation: [
        MichelineConstants.primitive: MichelineConstants.some,
        MichelineConstants.args: [
          some.networkRepresentation
        ]
      ],
      annotations: annotations
    )
  }
}
