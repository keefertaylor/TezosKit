// Copyright Keefer Taylor, 2019

import Base58Swift
import CommonCrypto
import CryptoSwift
import Foundation
import Sodium

/// A static helper class that provides utility functions for cyptography.
public enum TezosCryptoUtils {
  /// Check that a given address is valid public key hash.
  public static func validateAddress(address: String) -> Bool {
    // Decode bytes. This call verifies the checksum is correct.
    guard let decodedBytes = Base58.base58CheckDecode(address) else {
      return false
    }

    // Check that the prefix is correct.
    for (i, byte) in Prefix.Address.tz1.enumerated() where decodedBytes[i] != byte {
      return false
    }

    return true
  }

  /// Convert the given input bytes to hex.
  public static func binToHex(_ bin: [UInt8]) -> String? {
    return Sodium.shared.utils.bin2hex(bin)
  }

  /// Convert the given hex to binary.
  public static func hexToBin(_ hex: String) -> [UInt8]? {
    return Sodium.shared.utils.hex2bin(hex)
  }

  /// Convert signature bytes to their base58 representation.
  public static func base58(signature: [UInt8]) -> String? {
    return Base58.encode(message: signature, prefix: TezosCrypto.Prefix.Sign.signature)
  }

  /// Create injectable hex bytes from the given hex operation and signature bytes
  public static func injectableHex(_ hex: String, signature: [UInt8]) -> String? {
    guard let signatureHex = binToHex(signature) else {
      return nil
    }
    return injectableHex(hex, signatureHex: signatureHex)
  }

  /// Create injectable hex bytes from the given hex operation and a hex signature.
  public static func injectableHex(_ hex: String, signatureHex: String) -> String {
    return hex + signatureHex
  }
}
