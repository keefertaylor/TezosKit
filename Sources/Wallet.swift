import Foundation

public struct Wallet {
  public let publicKey: String
  public let privateKey: String
  public let address: String

  public init(keyPair: KeyPair) {
    self.publicKey = Crypto.tezosPublicKey(from: keyPair.publicKey)
    self.privateKey = Crypto.tezosPrivateKey(from: keyPair.privateKey);
    self.address = Crypto.tezosPublicKeyHash(from: keyPair.publicKey);
  }
}
