// Copyright Keefer Taylor, 2019.

import Foundation

/// A representation of a string parameter in Michelson.
public class StringMichelsonParameter: AbstractMichelsonParameter {
  public init(string: String, annotations: [MichelsonAnnotation]? = nil) {
    super.init(networkRepresentation: [MichelineConstants.string: string], annotations: annotations)
  }
}
