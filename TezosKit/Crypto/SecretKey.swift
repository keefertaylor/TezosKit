// Copyright Keefer Taylor, 2019

import Base58Swift
import Foundation
import MnemonicKit
import secp256k1
import Sodium

/// Encapsulation of a secret key.
public struct SecretKey {
  /// Underlying bytes
  public let bytes: [UInt8]

  /// The elliptical curve this key is using.
  public let signingCurve: EllipticalCurve

  /// Base58Check representation of the key.
  public var base58CheckRepresentation: String {
    switch signingCurve {
    case .ed25519:
      return Base58.encode(message: bytes, prefix: Prefix.Keys.Ed25519.secret)
    case .secp256k1:
      return Base58.encode(message: bytes, prefix: Prefix.Keys.Secp256k1.secret)
    case .p256:
      fatalError("Unimplemented")
    }
  }

  /// Initialize a key with the given mnemonic and passphrase.
  ///
  /// - Parameters:
  ///   - mnemonic: A mnemonic phrase to use.
  ///   - passphrase: An optional passphrase to use. Default is the empty string.
  ///   - signingCurve: The elliptical curve to use for the key. Defaults to ed25519.
  /// - Returns: A representative secret key, or nil if an invalid mnemonic was given.
  public init?(mnemonic: String, passphrase: String = "", signingCurve: EllipticalCurve = .ed25519) {
    guard let seedString = Mnemonic.deterministicSeedString(from: mnemonic, passphrase: passphrase) else {
      return nil
    }
    self.init(
      seedString: String(seedString[..<seedString.index(seedString.startIndex, offsetBy: 64)]),
      signingCurve: signingCurve
    )
  }

  /// Initialize a key with the given hex seed string.
  ///
  ///  - Parameters:
  ///    - seedString a hex encoded seed string.
  ///    - signingCurve: The elliptical curve to use for the key. Defaults to ed25519.
  /// - Returns: A representative secret key, or nil if the seed string was in an unexpected format.
  public init?(seedString: String, signingCurve: EllipticalCurve = .ed25519) {
    guard
      let seed = Sodium.shared.utils.hex2bin(seedString),
      let keyPair = Sodium.shared.sign.keyPair(seed: seed)
    else {
      return nil
    }

    self.init(keyPair.secretKey, signingCurve: .ed25519)
  }

  /// Initialize a secret key with the given base58check encoded string.
  ///
  ///  - Parameters:
  ///    - string: A base58check encoded string.
  ///    - signingCurve: The elliptical curve to use for the key. Defaults to ed25519.
  public init?(_ string: String, signingCurve: EllipticalCurve = .ed25519) {
    switch signingCurve {
    case .ed25519:
      guard let bytes = Base58.base58CheckDecodeWithPrefix(string: string, prefix: Prefix.Keys.Ed25519.secret) else {
        return nil
      }
      self.init(bytes)
    case .secp256k1:
      guard let bytes = Base58.base58CheckDecodeWithPrefix(string: string, prefix: Prefix.Keys.Secp256k1.secret) else {
        return nil
      }
      self.init(bytes, signingCurve: .secp256k1)
    case .p256:
      fatalError("Unimplemented")
    }
  }

  /// Initialize a key with the given bytes.
  ///  - Parameters:
  ///    - bytes: Raw bytes of the private key.
  ///    - signingCurve: The elliptical curve to use for the key. Defaults to ed25519.
  public init(_ bytes: [UInt8], signingCurve: EllipticalCurve = .ed25519) {
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
    guard let bytesToSign = prepareBytesForSigning(bytes) else {
      return nil
    }

    switch signingCurve {
    case .ed25519:
      return Sodium.shared.sign.signature(message: bytesToSign, secretKey: self.bytes)
    case .secp256k1:
      let context = secp256k1_context_create(UInt32(SECP256K1_CONTEXT_SIGN))!
      defer {
        secp256k1_context_destroy(context)
      }

      var signature = secp256k1_ecdsa_signature()
      let signatureLength = 64
      var output = [UInt8](repeating: 0, count: signatureLength)
      guard
        secp256k1_ecdsa_sign(context, &signature, bytesToSign, self.bytes, nil, nil) != 0,
        secp256k1_ecdsa_signature_serialize_compact(context, &output, &signature) != 0
      else {
        return nil
      }

      return output
    case .p256:
      fatalError("Unimplemented")
    }
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
