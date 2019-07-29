// Copyright Keefer Taylor, 2019.

import Foundation

/// A representation of a bytes parameter in Michelson.
public class BytesMichelsonParameter: CustomMichelsonParameter {
  public convenience init?(bytes: [UInt8]) {
    guard let hex = CodingUtil.binToHex(bytes) else {
      return nil
    }
    self.init(hex: hex)
  }

  public init(hex: Hex) {
    super.init(networkRepresentation: [ MichelineConstants.bytes: hex ])
  }
}
