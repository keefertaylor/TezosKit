// Copyright Keefer Taylor, 2019.

import Foundation
import TezosCrypto

/// Wrapper for cryptography utils.
public enum CodingUtil {
  public func binToHex(_ bin: [UInt8]) -> String? {
    return TezosCryptoUtils.binToHex(bin)
  }

  public func hexToBin(_ hex: String) -> [UInt8]? {
    return TezosCryptoUtils.hexToBin(hex)
  }
}
