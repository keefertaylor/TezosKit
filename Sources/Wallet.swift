import Foundation

public struct Wallet {

  public let publicKey: String

  public init(keyPair: KeyPair) {
    self.publicKey = Crypto.tezosPublicKey(from: keyPair.publicKey)
  }
}
