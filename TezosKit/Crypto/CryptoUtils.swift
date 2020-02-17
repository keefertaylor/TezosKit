// Copyright Keefer Taylor, 2019

import Base58Swift
import CommonCrypto
import CryptoSwift
import Foundation
import Sodium

/// A static helper class that provides utility functions for cyptography.
public enum CryptoUtils {
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
  public static func base58(signature: [UInt8], signingCurve: EllipticalCurve) -> String? {
    switch signingCurve {
    case .ed25519:
      return Base58.encode(message: signature, prefix: Prefix.Keys.Ed25519.signature)
    case .secp256k1:
      return Base58.encode(message: signature, prefix: Prefix.Keys.Secp256k1.signature)
    case .p256:
      return Base58.encode(message: signature, prefix: Prefix.Keys.P256.signature)
    }
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

  /// Compress a 65 byte public key to a 33 byte public key.
  ///
  /// Tezos expects usage of compressed keys.
  public static func compressKey(_ bytes: [UInt8]) -> [UInt8]? {
    // A magic byte 0x04 indicates that the key is uncompressed. Compressed keys use 0x02 and 0x03 to indicate the
    // key is compressed and the value of the Y coordinate of the keys.
    let rawPublicKeyBytes = Array(bytes)
    guard
      let firstByte = rawPublicKeyBytes.first,
      let lastByte = rawPublicKeyBytes.last,
      // Expect an uncompressed key to have length = 65 bytes (two 32 byte coordinates, and 1 magic prefix byte)
      rawPublicKeyBytes.count == 65,
      // Expect the first byte of the public key to be a magic 0x04 byte, indicating an uncompressed key.
      firstByte == 4
    else {
      return nil
    }

    // Assign a new magic byte based on the Y coordinate's parity.
    // See: https://bitcointalk.org/index.php?topic=644919.0
    let magicByte: [UInt8] = lastByte % 2 == 0 ? [2] : [3]
    let xCoordinateBytes = rawPublicKeyBytes[1...32]
    return magicByte + xCoordinateBytes
  }
}
