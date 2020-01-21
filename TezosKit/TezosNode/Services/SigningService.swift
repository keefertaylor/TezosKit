// Copyright Keefer Taylor, 2019.

import Base58Swift
import Foundation

/// An opaque object which implements public key cryptography functions.
public protocol SignatureProvider {
  func sign(_ hex: String) -> [UInt8]?
  var publicKey: PublicKeyProtocol { get }
}

/// Manages signing of transactions.
public enum SigningService {
  public static func sign(_ hex: String, with signatureProvider: SignatureProvider) -> [UInt8]? {
    return signatureProvider.sign(hex)
  }
}
