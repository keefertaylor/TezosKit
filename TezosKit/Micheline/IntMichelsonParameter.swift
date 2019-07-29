// Copyright Keefer Taylor, 2019.

import Foundation

/// A representation of an integer parameter in Michelson.
public class IntMichelsonParameter: CustomMichelsonParameter {
  public init(int: Int) {
    super.init(networkRepresentation: [MichelineConstants.int: "\(int)"])
  }
}
