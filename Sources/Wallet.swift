import Foundation

public struct Wallet {

  public let publicKey: String
  public let privateKey: String

  public init(keyPair: KeyPair) {
    self.publicKey = Crypto.tezosPublicKey(from: keyPair.publicKey)
    self.privateKey = Crypto.tezosPrivateKey(from: keyPair.privateKey);
  }
}
