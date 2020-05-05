// Copyright Keefer Taylor, 2020.

import Foundation

/// A representation of a signature parameter in Michelson.
public class SignatureMichelsonParameter: AbstractMichelsonParameter {
  /// Initialize a new address parameter.
  ///
  /// - Parameters:
  ///   - signature: A base58check encoded signature.
  ///   - annotations: An optional array of annotations to apply, default is none.
  public init(signature: String, annotations: [MichelsonAnnotation]? = nil) {
    super.init(networkRepresentation: [MichelineConstants.string: signature], annotations: annotations)
  }
}
