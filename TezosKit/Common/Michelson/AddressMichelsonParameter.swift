// Copyright Keefer Taylor, 2020.

import Foundation

/// A representation of a address parameter in Michelson.
public class AddressMichelsonParameter: AbstractMichelsonParameter {
  /// Initialize a new address parameter.
  ///
  /// - Parameters:
  ///   - address: An address.
  ///   - annotations: An optional array of annotations to apply, default is none.
  public init(address: String, annotations: [MichelsonAnnotation]? = nil) {
    super.init(networkRepresentation: [MichelineConstants.string: address], annotations: annotations)
  }
}
