import Foundation
import CKMnemonic

public struct Wallet {
  public let publicKey: String
  public let secretKey: String
  public let address: String

  /** Create a new wallet. */
  public init?() {
    // TODO: Generate bip39 mnemonic.
    let mnemonic = "soccer click number muscle police corn couch bitter gorilla camp camera shove expire praise pill"
    do {
      // Generate a 64 character seed string from the mnemonic.
      let rawSeedString = try CKMnemonic.deterministicSeedString(from: mnemonic, passphrase: "", language: .english)
      let seedString = String(rawSeedString[..<rawSeedString.index(rawSeedString.startIndex, offsetBy: 64)])

      // Use the seedString to generate a keypair.
      guard let keyPair = Crypto.keyPair(from: seedString) else {
        return nil
      }

      // Create a new wallet with the given keypair.
      self = Wallet(keyPair: keyPair)
    } catch {
      return nil
    }
  }

  /** Create a new wallet with the given keypair. */
  private init(keyPair: KeyPair) {
    self.publicKey = Crypto.tezosPublicKey(from: keyPair.publicKey)
    self.secretKey = Crypto.tezosSecretKey(from: keyPair.secretKey);
    self.address = Crypto.tezosPublicKeyHash(from: keyPair.publicKey);
  }

  // TODO: Add support for passphrase generation.
}
