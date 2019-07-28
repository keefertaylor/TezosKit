// Copyright Keefer Taylor, 2019.

import Foundation

/// A representation of a bytes parameter in micheline.
public struct MichelineBytesParam: MichelineParam {
  public let networkRepresentation: [String: Any]

  public init?(bytes: [UInt8]) {
    guard let hex = CodingUtil.binToHex(bytes) else {
      return nil
    }
    self.init(hex: hex)
  }

  public init(hex: Hex) {
    self.networkRepresentation = [ MichelineConstants.bytes: hex ]
  }
}
