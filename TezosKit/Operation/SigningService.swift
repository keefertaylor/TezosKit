// Copyright Keefer Taylor, 2019.

import Base58Swift
import Foundation
import TezosCrypto
import Sodium

/// An object which can sign transactions.
public protocol Signer {
  func sign(_ hex: String) -> [UInt8]?
  var publicKey: PublicKey { get }
}

/// Manages signing of transactions.
public enum SigningService {
  public static func sign(_ hex: String, with signer: Signer) -> [UInt8]? {
    return signer.sign(hex)
  }
}
