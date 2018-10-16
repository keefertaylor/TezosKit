import Foundation
import Sodium

public struct Wallet {
  public let publicKey: String
  public let privateKey: String
  public let address: String

  /** Create a new wallet. */
  public init?() {
    // TODO: Generate seed string from mnenomomonic.
    let seedString = "cce78b57ed8f4ec6767ed35f3aa41df525a03455e24bcc45a8518f63fbeda772"

    let sodium = Sodium()
    guard let seed = sodium.utils.hex2bin(seedString),
          let keyPair = sodium.sign.keyPair(seed: seed) else {
          return nil
    }

    self = Wallet(keyPair: keyPair)
  }

  /** Create a new wallet with the given keypair. */
  private init(keyPair: KeyPair) {
    self.publicKey = Crypto.tezosPublicKey(from: keyPair.publicKey)
    self.privateKey = Crypto.tezosPrivateKey(from: keyPair.privateKey);
    self.address = Crypto.tezosPublicKeyHash(from: keyPair.publicKey);
  }

  // TODO: Add support for passphrase generation.
}
