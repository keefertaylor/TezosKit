// Copyright Keefer Taylor, 2019.

import Base58Swift
import Foundation
import Sodium

/// Encapsulation of a Public Key.
public struct PublicKey: PublicKeyProtocol {
  /// Underlying bytes.
  public let bytes: [UInt8]

  /// The elliptical curve this key is using.
  public let signingCurve: EllipticalCurve

  /// Base58Check representation of the key.
  public var base58CheckRepresentation: String {
    switch signingCurve {
    case .ed25519:
      return Base58.encode(message: bytes, prefix: Prefix.Keys.public)
    case .secp256k1:
      fatalError("Unimplemented")
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
      fatalError("Unimplemented")
    }
  }

  /// Initialize a key with the given bytes and signing curve.
  public init(bytes: [UInt8], signingCurve: EllipticalCurve) {
    self.bytes = bytes
    self.signingCurve = signingCurve
  }

  /// Initialize a public key with the given base58check encoded string.
  public init?(string: String, signingCurve: EllipticalCurve) {
    switch signingCurve {
    case .ed25519:
      guard let bytes = Base58.base58CheckDecodeWithPrefix(string: string, prefix: Prefix.Keys.public) else {
        return nil
      }
      self.init(bytes: bytes, signingCurve: signingCurve)
    case .secp256k1:
      fatalError("Unimplemented")
    }
  }

  /// Initialize a key from the given secret key with the given signing curve.
  public init(secretKey: SecretKey, signingCurve: EllipticalCurve) {
    switch signingCurve {
    case .ed25519:
      self.bytes = Array(secretKey.bytes[32...])
      self.signingCurve = signingCurve
    case .secp256k1:
      fatalError("Unimplemented")
    }
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
      fatalError("Unimplemented")
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
