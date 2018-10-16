import Foundation

public struct Wallet {
  public let publicKey: String
  public let secretKey: String
  public let address: String

  /** Create a new wallet. */
  public init?() {
    // TODO: Generate seed string from mnenomomonic.
    let seedString = "cce78b57ed8f4ec6767ed35f3aa41df525a03455e24bcc45a8518f63fbeda772"
    guard let keyPair = Crypto.keyPair(from: seedString) else {
      return nil
    }
    self = Wallet(keyPair: keyPair)
  }

  /** Create a new wallet with the given keypair. */
  private init(keyPair: KeyPair) {
    self.publicKey = Crypto.tezosPublicKey(from: keyPair.publicKey)
    self.secretKey = Crypto.tezosSecretKey(from: keyPair.secretKey);
    self.address = Crypto.tezosPublicKeyHash(from: keyPair.publicKey);
  }

  // TODO: Add support for passphrase generation.
}
