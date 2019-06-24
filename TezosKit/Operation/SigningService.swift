// Copyright Keefer Taylor, 2019.

import Base58Swift
import Foundation
import TezosCrypto
import Sodium

/// An object which can sign transactions.
public protocol Signer {
  func sign(_ hex: String) -> [UInt8]?
}

/// Manages signing of transactions.
public enum SigningService {
  public static func sign(_ hex: String, with signer: Signer) -> [UInt8]? {
    return signer.sign(hex)
  }
}

extension TezosCrypto.SecretKey: Signer {
  public func sign(_ hex: String) -> [UInt8]? {
    return TezosCryptoUtils.signToSig(hex: hex, secretKey: self)
  }
}

extension Keys: Signer {
  public func sign(_ hex: String) -> [UInt8]? {
    return secret.sign(hex)
  }
}

extension Wallet: Signer {
  public func sign(_ hex: String) -> [UInt8]? {
    guard let secretKey = self.keys.secretKey as? TezosCrypto.SecretKey else {
      return nil
    }
    return secretKey.sign(hex)
  }
}

/// TODO: Modify TezosCryptoUtils to be like this.
extension TezosCryptoUtils {
  fileprivate static func signToSig(hex: String, secretKey: TezosCrypto.SecretKey) -> [UInt8]? {
    guard let signingResult = TezosCryptoUtils.sign(hex: hex, secretKey: secretKey) else {
      return nil
    }
    return signingResult.signature
  }

  public static func binToHex(_ bin: [UInt8]) -> String? {
    return Sodium.shared.utils.bin2hex(bin)
  }

  public static func hexToBin(_ hex: String) -> [UInt8]? {
    return Sodium.shared.utils.hex2bin(hex)
  }

  public static func base58(signature: [UInt8]) -> String? {
    return Base58.encode(message: signature, prefix: TezosCrypto.Prefix.Sign.operation)
  }
}
