import Foundation
import Sodium

/** Generic KeyPair protocol containing private and public keys. */
// TODO: Refactor 'privateKey' to 'secretKey' to play nicely with Sodium's model object.
public protocol KeyPair {
  var publicKey: [UInt8] { get }
  var privateKey: [UInt8] { get }
}

/** Generic KeyPair struct. */
public struct DefaultKeyPair: KeyPair {
  public let publicKey: [UInt8]
  public let privateKey: [UInt8]
}

/** Extension on Sodium's Sign.KeyPair to work with TezosKit code. */
extension Sign.KeyPair: KeyPair {
  public var privateKey: [UInt8] {
    return secretKey
  }
}
