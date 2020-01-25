// Copyright Keefer Taylor, 2019

import Base58Swift
import Foundation
import Sodium

/// A property bag representing various artifacts from signing bytes.
public struct SigningResult {
  /// The original bytes which were signed.
  public let bytes: [UInt8]

  /// The hashed bytes which were produced via hashing and signed.
  public let hashedBytes: [UInt8]

  /// The signature of the hashed bytes.
  public let signature: [UInt8]

  /// The base58check encoded version of the signature, prefixed with 'edsig'
  public var base58Representation: String

  /// The original bytes concatenated with their signature in hex.
  public let injectableHexBytes: String

  /// - Parameters:
  ///   - bytes: The original bytes.
  ///   - hashedBytes: The hashed bytes which were signed.
  ///   - signature: The signature from the bytes.
  public init?(bytes: [UInt8], hashedBytes: [UInt8], signature: [UInt8], prefix: [UInt8]) {
    guard let bytesHex = Sodium.shared.utils.bin2hex(bytes),
          let signatureHex = Sodium.shared.utils.bin2hex(signature) else {
      return nil
    }
    let edsig = Base58.encode(message: signature, prefix: prefix)

    self.bytes = bytes
    self.hashedBytes = hashedBytes
    self.signature = signature
    self.injectableHexBytes = bytesHex + signatureHex
    self.base58Representation = edsig
  }
}

extension SigningResult: CustomStringConvertible {
  public var description: String {
    return base58Representation
  }
}
