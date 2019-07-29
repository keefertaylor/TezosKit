// Copyright Keefer Taylor, 2019.

import Foundation

// A representation of a some parameter in Michelson.
public class SomeMichelsonParameter: CustomMichelsonParameter {
  public init(some: MichelsonParameter) {
    super.init(
      networkRepresentation: [
        MichelineConstants.primitive: MichelineConstants.some,
        MichelineConstants.args: [
          some.networkRepresentation
        ]
      ]
    )
  }
}
