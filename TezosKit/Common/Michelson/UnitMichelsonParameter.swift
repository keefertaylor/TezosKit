// Copyright Keefer Taylor, 2019.

import Foundation

/// A representation of an unit parameter in Michelson.
public class UnitMichelsonParameter: AbstractMichelsonParameter {
  public init(annotations: [MichelsonAnnotation]? = nil) {
    super.init(
      networkRepresentation: [ MichelineConstants.primitive: MichelineConstants.unit ],
      annotations: annotations
    )
  }
}
