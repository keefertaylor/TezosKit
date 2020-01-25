// Copyright Keefer Taylor, 2019

import Base58Swift
import Foundation
import MnemonicKit
import Sodium

/// Encapsulation of a secret key.
public struct SecretKey {
  /// Underlying bytes
  public let bytes: [UInt8]

  // TODO: Pull this automagically in PublicKey
  public let signingCurve: EllipticalCurve

  /// Base58Check representation of the key, prefixed with 'espk'.
  public var base58CheckRepresentation: String {
    switch signingCurve {
    case .ed25519:
      return Base58.encode(message: bytes, prefix: Prefix.Keys.secret)
    case .secp256k1:
      return Base58.encode(message: bytes, prefix: Prefix.Secp.secret)
    }
  }

  /// Initialize a key with the given mnemonic and passphrase.
   ///
   /// - Parameters:
   ///   - mnemonic: A mnemonic phrase to use.
   ///   - passphrase: An optional passphrase to use. Default is the empty string.
   /// - Returns: A representative secret key, or nil if an invalid mnemonic was given.
   public init?(mnemonic: String, passphrase: String = "", signingCurve: EllipticalCurve) {
     guard let seedString = Mnemonic.deterministicSeedString(from: mnemonic, passphrase: passphrase) else {
       return nil
     }
     self.init(seedString: String(seedString[..<seedString.index(seedString.startIndex, offsetBy: 64)]), signingCurve: signingCurve)
   }

   /// Initialize a key with the given hex seed string.
   ///
   /// - Returns: A representative secret key, or nil if the seed string was in an unexpected format.
   public init?(seedString: String, signingCurve: EllipticalCurve) {
     guard let seed = Sodium.shared.utils.hex2bin(seedString),
           let keyPair = Sodium.shared.sign.keyPair(seed: seed) else {
             return nil
     }
     self.init(keyPair.secretKey, signingCurve: signingCurve)
   }

  /// Initialize a secret key with the given base58check encoded string.
  ///
  /// The string must begin with 'edsk'.
  public init?(_ string: String, signingCurve: EllipticalCurve) {
    switch signingCurve {
    case .ed25519:
      if let bytes = Base58.base58CheckDecodeWithPrefix(string: string, prefix: Prefix.Keys.secret) {
        self.init(bytes, signingCurve: .ed25519)
      } else if let bytes = Base58.base58CheckDecodeWithPrefix(string: string, prefix: Prefix.Keys.seed),
        let keyPair = Sodium.shared.sign.keyPair(seed: bytes) {
        self.init(keyPair.secretKey, signingCurve: .ed25519)
      } else {
        return nil
      }
    case .secp256k1:
      guard let bytes = Base58.base58CheckDecodeWithPrefix(string: string, prefix: Prefix.Secp.secret) else {
        return nil
      }
      self.init(bytes, signingCurve: .secp256k1)
    }
  }

  /// Initialize a key with the given bytes.
  public init(_ bytes: [UInt8], signingCurve: EllipticalCurve) {
    self.bytes = bytes
    self.signingCurve = signingCurve
  }
  /// Sign the given hex encoded string with the given key.
  ///
  /// - Parameters:
  ///   - hex: The hex string to sign.
  ///   - secretKey: The secret key to sign with.
  /// - Returns: A signature from the input.
  public func sign(hex: String) -> [UInt8]? {
    guard let bytes = Sodium.shared.utils.hex2bin(hex) else {
      return nil
    }
    return self.sign(bytes: bytes)
  }

  /// Sign the given hex encoded string with the given key.
  ///
  /// - Parameters:
  ///   - hex: The hex string to sign.
  ///   - secretKey: The secret key to sign with.
  /// - Returns: A signature from the input.
  public func sign(bytes: [UInt8]) -> [UInt8]? {
    guard let bytesToSign = prepareBytesForSigning(bytes),
      let signature = Sodium.shared.sign.signature(message: bytesToSign, secretKey: self.bytes) else {
        return nil
    }
    return signature
  }

  /// Prepare bytes for signing by applying a watermark and hashing.
  private func prepareBytesForSigning(_ bytes: [UInt8]) -> [UInt8]? {
    let watermarkedOperation = Prefix.Watermark.operation + bytes
    return Sodium.shared.genericHash.hash(message: watermarkedOperation, outputLength: 32)
  }
}

extension SecretKey: CustomStringConvertible {
  public var description: String {
    return base58CheckRepresentation
  }
}

extension SecretKey: Equatable {
  public static func == (lhs: SecretKey, rhs: SecretKey) -> Bool {
    return lhs.base58CheckRepresentation == rhs.base58CheckRepresentation
  }
}
