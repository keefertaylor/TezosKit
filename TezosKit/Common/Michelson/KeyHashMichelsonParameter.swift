// Copyright Keefer Taylor, 2019.

import Foundation

/// A representation of a key hash parameter in Michelson.
public class KeyHashMichelsonParameter: AbstractMichelsonParameter {
  public convenience init?(keyHashBytes: [UInt8], annotations: [MichelsonAnnotation]? = nil) {
    guard let hex = CryptoUtils.binToHex(keyHashBytes) else {
      return nil
    }
    self.init(keyHashHex: hex, annotations: annotations)
  }

  public init(keyHashHex: Hex, annotations: [MichelsonAnnotation]? = nil) {
    super.init(networkRepresentation: [ MichelineConstants.bytes: keyHashHex ], annotations: annotations)
  }
}
