// Copyright Keefer Taylor, 2019.

import Foundation

/// A representation of an integer parameter in Michelson.
public class IntMichelsonParameter: AbstractMichelsonParameter {
  public init(int: Int, annotations: [MichelsonAnnotation]? = nil) {
    super.init(networkRepresentation: [MichelineConstants.int: "\(int)"], annotations: annotations)
  }
}
