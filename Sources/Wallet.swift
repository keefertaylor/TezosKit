import Foundation

public struct Wallet {
  public let publicKey: String
  public let secretKey: String
  public let address: String
  public let mnemonic: String

  /** Create a new wallet by generating a mnemonic. */
  public init?(mnemonic: String) {
    // TODO: Generate bip39 mnemonic.
    let mnemonic =  "soccer click number muscle police corn couch bitter gorilla camp camera shove expire praise pill"
    guard let seedString =  MnemonicUtil.seedString(from: mnemonic),
          let keyPair = Crypto.keyPair(from: seedString) else {
        return nil
    }

    self.init(publicKey: Crypto.tezosPublicKey(from: keyPair.publicKey),
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
}
