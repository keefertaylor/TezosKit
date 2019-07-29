// Copyright Keefer Taylor, 2019.

import Foundation

/// A representation of an unit parameter in Michelson.
public class UnitMichelsonParameter: CustomMichelsonParameter {
  public init() {
    super.init(networkRepresentation: [ MichelineConstants.primitive: MichelineConstants.unit ])
  }
}
