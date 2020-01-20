// Copyright Keefer Taylor, 2019

import Foundation
import Sodium

/// Generic KeyPair protocol containing private and public keys.
public protocol KeyPair {
  var `public`: TezosCrypto.PublicKey { get }
  var secret: TezosCrypto.SecretKey { get }
}

/// Extension on Sodium's Sign.KeyPair to work with TezosKit code.
extension Sign.KeyPair: KeyPair {
  public var secret: TezosCrypto.SecretKey {
    return TezosCrypto.SecretKey(secretKey)
  }

  public var `public`: TezosCrypto.PublicKey {
    return TezosCrypto.PublicKey(bytes: publicKey, signingCurve: .ed25519)
  }
}
