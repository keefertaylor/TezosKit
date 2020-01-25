// Copyright Keefer Taylor, 2019.

import Base58Swift
import Foundation
import secp256k1
import Sodium

/// Encapsulation of a Public Key.
public struct PublicKey: PublicKeyProtocol {
  /// Underlying bytes.
  public let bytes: [UInt8]

  /// Curve type.
  public let signingCurve: EllipticalCurve

  /// Base58Check representation of the key, prefixed with 'edpk'.
  public var base58CheckRepresentation: String {
    switch signingCurve {
    case .ed25519:
      return Base58.encode(message: bytes, prefix: Prefix.Keys.public)
    case .secp256k1:
      return Base58.encode(message: bytes, prefix: Prefix.Secp.public)
    }

    return Base58.encode(message: bytes, prefix: Prefix.Keys.public)
  }

  /// Public key hash representation of the key.
  public var publicKeyHash: String {
    // swiftlint:disable force_unwrapping
    // Hashing should never fail on a valid public key.
    let hash = Sodium.shared.genericHash.hash(message: bytes, outputLength: 20)!
    // swiftlint:enable force_unwrapping

    switch signingCurve {
    case .ed25519:
      return Base58.encode(message: hash, prefix: Prefix.Address.tz1)
    case .secp256k1:
      return Base58.encode(message: hash, prefix: Prefix.Address.tz2)
    }
  }

  /// Initialize a key with the given bytes and signing curve.
  public init(bytes: [UInt8], signingCurve: EllipticalCurve) {
    self.signingCurve = signingCurve
    switch signingCurve {
    case .ed25519:
      self.bytes = bytes
    case .secp256k1:
      self.bytes = bytes
    }
  }

  /// Initialize a public key with the given base58check encoded string.
  ///
  /// The string must begin with 'edpk'.
  public init?(string: String, signingCurve: EllipticalCurve) {
    guard let bytes = Base58.base58CheckDecodeWithPrefix(string: string, prefix: Prefix.Keys.public) else {
      return nil
    }
    self.init(bytes: bytes, signingCurve: signingCurve)
  }

  /// Initialize a key from the given secret key with the given signing curve.
  public init(secretKey: SecretKey, signingCurve: EllipticalCurve) {
    switch signingCurve {
    case .ed25519:
      self.bytes = Array(secretKey.bytes[32...])
    case .secp256k1:
      let context = secp256k1_context_create(UInt32(SECP256K1_CONTEXT_SIGN))!
      var cPubkey = secp256k1_pubkey()
      let result = secp256k1_ec_pubkey_create(context, &cPubkey, secretKey.bytes)

      var pubKeyLen = 33
      var pubkey: [UInt8] = Array(repeating: 0, count: pubKeyLen)
      let result2 = secp256k1_ec_pubkey_serialize(context, &pubkey, &pubKeyLen, &cPubkey, UInt32(SECP256K1_EC_COMPRESSED))
      self.bytes = pubkey
    }
    self.signingCurve = signingCurve
  }

  /// Verify that the given signature matches the given input hex.
  ///
  /// - Parameters:
  ///   - hex: The hex to check.
  ///   - signature: The proposed signature of the bytes.
  ///   - publicKey: The proposed public key.
  /// - Returns: True if the public key and signature match the given bytes.
  public func verify(signature: [UInt8], hex: String) -> Bool {
    guard let bytes = Sodium.shared.utils.hex2bin(hex) else {
      return false
    }
    return verify(signature: signature, bytes: bytes)
  }

  /// Verify that the given signature matches the given input bytes.
  ///
  /// - Parameters:
  ///   - bytes: The bytes to check.
  ///   - signature: The proposed signature of the bytes.
  ///   - publicKey: The proposed public key.
  /// - Returns: True if the public key and signature match the given bytes.
  public func verify(signature: [UInt8], bytes: [UInt8]) -> Bool {
    guard let bytesToVerify = prepareBytesForVerification(bytes) else {
      return false
    }

    switch signingCurve {
    case .ed25519:
      return Sodium.shared.sign.verify(message: bytesToVerify, publicKey: self.bytes, signature: signature)
    case .secp256k1:
      // TODO(keefertaylor): Implement
      return false
    }
  }

  /// Prepare bytes for verification by applying a watermark and hashing.
  private func prepareBytesForVerification(_ bytes: [UInt8]) -> [UInt8]? {
    let watermarkedOperation = Prefix.Watermark.operation + bytes
    return Sodium.shared.genericHash.hash(message: watermarkedOperation, outputLength: 32)
  }
}

extension PublicKey: CustomStringConvertible {
  public var description: String {
    return base58CheckRepresentation
  }
}

extension PublicKey: Equatable {
  public static func == (lhs: PublicKey, rhs: PublicKey) -> Bool {
    return lhs.base58CheckRepresentation == rhs.base58CheckRepresentation
  }
}
