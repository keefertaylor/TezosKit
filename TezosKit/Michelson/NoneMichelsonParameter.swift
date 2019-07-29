// Copyright Keefer Taylor, 2019.

import Foundation

/// A representation of a none param in Michelson.
public class NoneMichelsonParameter: AbstractMichelsonParameter {
  public init() {
    super.init(networkRepresentation: [ MichelineConstants.primitive: MichelineConstants.none ])
  }
}
