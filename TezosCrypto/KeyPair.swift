// Copyright Keefer Taylor, 2019

import Foundation
import Sodium

/// Generic KeyPair protocol containing private and public keys.
public protocol KeyPair {
  var `public`: CryptoPublicKey { get }
  var secret: CryptoSecretKey { get }
}

/// Extension on Sodium's Sign.KeyPair to work with TezosKit code.
extension Sign.KeyPair: KeyPair {
  public var secret: CryptoSecretKey {
    return CryptoSecretKey(secretKey, signingCurve: .ed25519)
  }

  public var `public`: CryptoPublicKey {
    return CryptoPublicKey(bytes: publicKey, signingCurve: .ed25519)
  }
}
