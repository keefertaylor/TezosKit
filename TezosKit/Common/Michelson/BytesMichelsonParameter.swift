// Copyright Keefer Taylor, 2019.

import Foundation

/// A representation of a bytes parameter in Michelson.
public class BytesMichelsonParameter: AbstractMichelsonParameter {
  public convenience init?(bytes: [UInt8], annotations: [MichelsonAnnotation]? = nil) {
    guard let hex = CryptoUtils.binToHex(bytes) else {
      return nil
    }
    self.init(hex: hex, annotations: annotations)
  }

  public init(hex: Hex, annotations: [MichelsonAnnotation]? = nil) {
    super.init(networkRepresentation: [ MichelineConstants.bytes: hex ], annotations: annotations)
  }
}
