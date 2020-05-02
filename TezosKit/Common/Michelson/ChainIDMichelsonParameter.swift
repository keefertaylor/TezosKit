// Copyright Keefer Taylor, 2019.

import Foundation

/// A representation of a chain ID parameter in Michelson.
public class ChainIDMichelsonParameter: AbstractMichelsonParameter {
  public convenience init?(chainIDBytes: [UInt8], annotations: [MichelsonAnnotation]? = nil) {
    guard let hex = CryptoUtils.binToHex(chainIDBytes) else {
      return nil
    }
    self.init(chainIDHex: hex, annotations: annotations)
  }

  public init(chainIDHex: Hex, annotations: [MichelsonAnnotation]? = nil) {
    super.init(networkRepresentation: [ MichelineConstants.bytes: chainIDHex ], annotations: annotations)
  }
}
