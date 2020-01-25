// Copyright Keefer Taylor, 2019.

import Base58Swift
import Foundation
import Sodium
import secp256k1

/// Encapsulation of a Public Key.
public struct CryptoPublicKey {
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
    case .secp256r1:
      return Base58.encode(message: bytes, prefix: Prefix.Nist.public)
    }
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
    case .secp256r1:
      return Base58.encode(message: hash, prefix: Prefix.Address.tz3_real)
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
    case .secp256r1:
      self.bytes = [0]
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
  public init(secretKey: CryptoSecretKey, signingCurve: EllipticalCurve) {
    switch signingCurve {
    case .ed25519:
      self.bytes = Array(secretKey.bytes[32...])
    case .secp256k1:
      let context = secp256k1_context_create(UInt32(SECP256K1_CONTEXT_SIGN))!
      var cPubkey = secp256k1_pubkey()
      let result = secp256k1_ec_pubkey_create(context, &cPubkey, secretKey.bytes)

      var pubKeyLen = 33
      var pubkey: [UInt8] = Array(repeating: 0, count: pubKeyLen)
      let result2 = secp256k1_ec_pubkey_serialize(context, &pubkey, &pubKeyLen, &cPubkey, UInt32(SECP256K1_EC_COMPRESSED));
      self.bytes = pubkey
    case .secp256r1:
      self.bytes = [0]
    }
    self.signingCurve = signingCurve
  }
}

extension CryptoPublicKey: CustomStringConvertible {
  public var description: String {
    return base58CheckRepresentation
  }
}

extension CryptoPublicKey: Equatable {
  public static func == (lhs: CryptoPublicKey, rhs: CryptoPublicKey) -> Bool {
    return lhs.base58CheckRepresentation == rhs.base58CheckRepresentation
  }
}
