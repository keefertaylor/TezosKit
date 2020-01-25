// Copyright Keefer Taylor, 2019

import Base58Swift
import CommonCrypto
import CryptoSwift
import Foundation
import Sodium
import secp256k1

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

  /// Verify that the given signature matches the given input bytes.
  ///
  /// - Parameters:
  ///   - bytes: The bytes to check.
  ///   - signature: The proposed signature of the bytes.
  ///   - publicKey: The proposed public key.
  /// - Returns: True if the public key and signature match the given bytes.
  public static func verifyBytes(bytes: [UInt8], signature: [UInt8], publicKey: CryptoPublicKey) -> Bool {
    switch publicKey.signingCurve {
    case .ed25519:
      return Sodium.shared.sign.verify(message: bytes, publicKey: publicKey.bytes, signature: signature)
    case .secp256k1:
      return false
    case .secp256r1:
      return false
    }
  }

  /// Sign the given hex encoded string with the given key.
  ///
  /// - Parameters:
  ///   - hex: The hex string to sign.
  ///   - secretKey: The secret key to sign with.
  /// - Returns: A property bag of artifacts from the signing operation.
  public static func sign(hex: String, secretKey: CryptoSecretKey) -> SigningResult? {
    guard let bytes = Sodium.shared.utils.hex2bin(hex) else {
      return nil
    }
    return self.sign(bytes: bytes, secretKey: secretKey)
  }

  /// Sign the given hex encoded string with the given key.
  ///
  /// - Parameters:
  ///   - hex: The hex string to sign.
  ///   - secretKey: The secret key to sign with.
  /// - Returns: A property bag of artifacts from the signing operation.
  public static func sign(bytes: [UInt8], secretKey: CryptoSecretKey) -> SigningResult? {
    let watermarkedOperation = Prefix.Watermark.operation + bytes

    guard let hashedBytes = Sodium.shared.genericHash.hash(message: watermarkedOperation, outputLength: 32) else {
        return nil
    }

    switch secretKey.signingCurve {
    case .ed25519:
      let signature = Sodium.shared.sign.signature(message: hashedBytes, secretKey: secretKey.bytes)!
      return SigningResult(bytes: bytes, hashedBytes: hashedBytes, signature: signature, prefix: Prefix.Sign.operation)
    case .secp256k1:
      let context = secp256k1_context_create(UInt32(SECP256K1_CONTEXT_SIGN | SECP256K1_CONTEXT_VERIFY))!
      var cSignature = secp256k1_ecdsa_signature()
      let sig = secp256k1_ecdsa_sign(context, &cSignature, hashedBytes, secretKey.bytes, nil, nil)

      let sigLen = 64
      var output = [UInt8](repeating: 0, count: sigLen)
      let serResult = secp256k1_ecdsa_signature_serialize_compact(context, &output, &cSignature)

//      let signature = try! Secp.sign(msg: hashedBytes, with: secretKey.bytes, nonceFunction: .rfc6979)
      return SigningResult(bytes: bytes, hashedBytes: hashedBytes, signature: output, prefix: Prefix.Secp.sig)
    case .secp256r1:
      return nil
    }
  }

  public static func signNIST(bytes: [UInt8], secretKey: CryptoSecretKey) -> SigningResult? {
    let watermarkedOperation = Prefix.Watermark.operation + bytes

    guard let hashedBytes = Sodium.shared.genericHash.hash(message: watermarkedOperation, outputLength: 32) else {
      return nil
    }

    return nil
  }
}
