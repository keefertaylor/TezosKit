import Foundation

public protocol KeyPair {
  var publicKey: [UInt8] { get }
  var privateKey: [UInt8] { get }
}

public struct DefaultKeyPair: KeyPair {
  public let publicKey: [UInt8]
  public let privateKey: [UInt8]
}

// TODO: Extend Sodium's Keypair behind this protocol when I can cajole Sodium into signing
//       correctly
