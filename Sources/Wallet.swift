import Foundation
import CKMnemonic

public struct Wallet {
  public let publicKey: String
  public let secretKey: String
  public let address: String
  public let mnemonic: String

  /** Create a new wallet by generating a mnemonic. */
  public init?() {
    // TODO: Generate bip39 mnemonic.
    let mnemonic =
        "soccer click number muscle police corn couch bitter gorilla camp camera shove expire praise pill"
    guard let seedString =  type(of: self).seedString(from: mnemonic),
          let keyPair = Crypto.keyPair(from: seedString) else {
        return nil
    }
    self = Wallet(publicKey: Crypto.tezosPublicKey(from: keyPair.publicKey),
                  secretKey: Crypto.tezosSecretKey(from: keyPair.secretKey),
                  address: Crypto.tezosPublicKeyHash(from: keyPair.publicKey),
                  mnemonic: mnemonic)
   }

  /** Create a new wallet with the given keypair. */
  private init(publicKey: String, secretKey: String, address: String, mnemonic: String) {
    self.publicKey = publicKey
    self.secretKey = secretKey
    self.address = address
    self.mnemonic = mnemonic
  }

  // TODO: Add support for passphrase generation.

  /**
   * Generate a seed string from a given mnemonic.
   *
   * This function is really just wrapping exception handling with an optional as syntactic sugar.
   */
  private static func seedString(from mnemonic: String) -> String? {
    do {
      // Generate a 64 character seed string from the mnemonic.
      let rawSeedString =
          try CKMnemonic.deterministicSeedString(from: mnemonic, passphrase: "", language: .english)
      return String(rawSeedString[..<rawSeedString.index(rawSeedString.startIndex, offsetBy: 64)])
    } catch {
      return nil
    }
  }
}
