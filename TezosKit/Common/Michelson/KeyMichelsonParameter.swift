// Copyright Keefer Taylor, 2019.

import Foundation

/// A representation of a key parameter in Michelson.
public class KeyMichelsonParameter: AbstractMichelsonParameter {
  /// Initialize a new parameter using a secret key.
  public convenience init(secretKey: SecretKey, annotations: [MichelsonAnnotation]? = nil) {
    self.init(string: secretKey.base58CheckRepresentation, annotations: annotations)
  }

  /// Initialize a new parameter using a public key.
  public convenience init(publicKey: PublicKeyProtocol, annotations: [MichelsonAnnotation]? = nil) {
    self.init(string: publicKey.base58CheckRepresentation, annotations: annotations)
  }

  /// Private initializer which receives a base58check representation of a key.
  private init(string: String, annotations: [MichelsonAnnotation]? = nil) {
    super.init(networkRepresentation: [MichelineConstants.string: string], annotations: annotations)
  }
}
