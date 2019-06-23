// Copyright Keefer Taylor, 2019.

import Foundation
import TezosCrypto

/// An object which can sign transactions.
public protocol Signer {
  func sign(_ hex: String) -> SigningResult?
}

/// Manages signing of transactions.
public enum SigningService {
  public static func sign(_ hex: String, with signer: Signer) -> SigningResult? {
    return signer.sign(hex)
  }
}

extension TezosCrypto.SecretKey: Signer {
  public func sign(_ hex: String) -> SigningResult? {
    return TezosCryptoUtils.sign(hex: hex, secretKey: self)
  }
}
