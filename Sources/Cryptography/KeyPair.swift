// Copyright Keefer Taylor, 2018

import Foundation
import Sodium

/** Generic KeyPair protocol containing private and public keys. */
public protocol KeyPair {
  var publicKey: [UInt8] { get }
  var secretKey: [UInt8] { get }
}

/** Extension on Sodium's Sign.KeyPair to work with TezosKit code. */
extension Sign.KeyPair: KeyPair {}
