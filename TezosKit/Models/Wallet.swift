// Copyright Keefer Taylor, 2018

import Foundation
import TezosCrypto

/// A model of a wallet in the Tezos ecosystem.
///
/// Clients can create a new wallet by calling the empty initializer. Clients can also restore an existing wallet by
/// providing an mnemonic and optional passphrase.
public struct Wallet {
  /// Keys for the wallet.
  public let keys: Keys

  /// A base58check encoded public key hash for the wallet, prefixed with "tz1" which represents an address in the Tezos
  /// ecosystem.
  public let address: String

  /// If this wallet was gnerated from a mnemonic, a space delimited string of english mnemonic words
  /// used to generate the wallet with the BIP39 specification, otherwise nil.
  public let mnemonic: String?

  /// Create a new wallet by generating a mnemonic and encrypted with an optional passphrase.
  ///
  ///- Parameter passphrase: An optional passphrase used for encryption.
  public init?(passphrase: String = "") {
    guard let mnemonic = MnemonicUtil.generateMnemonic() else {
      return nil
    }
    self.init(mnemonic: mnemonic, passphrase: passphrase)
  }

  /// Create a new wallet with the given mnemonic and encrypted with an optional passphrase.
  ///
  /// - Parameters:
  ///   - mnemonic: A space delimited string of english mnemonic words from the BIP39
  ///   - passphrase: An optional passphrase used for encryption.
  public init?(mnemonic: String, passphrase: String = "") {
    guard let seedString = MnemonicUtil.seedString(from: mnemonic, passphrase: passphrase),
      let secretKey = TezosCrypto.SecretKey(seedString: seedString) else {
      return nil
    }

    let publicKey = TezosCrypto.PublicKey(secretKey: secretKey, signingCurve: .ed25519)
    let address = publicKey.publicKeyHash
    let keys = Keys(publicKey: publicKey, secretKey: secretKey)
    self.init(address: address, keys: keys, mnemonic: mnemonic)
  }

  /// Create a wallet with a given secret key.
  ///
  /// - Parameter secretKey: A base58check encoded secret key, prefixed with "edsk".
  public init?(secretKey: String) {
    guard let secretKey = TezosCrypto.SecretKey(secretKey) else {
      return nil
    }

    let publicKey = TezosCrypto.PublicKey(secretKey: secretKey, signingCurve: .ed25519)
    let address = publicKey.publicKeyHash
    let keys = Keys(publicKey: publicKey, secretKey: secretKey)
    self.init(address: address, keys: keys)
  }

  /// Create a wallet with the given address and keys.
  ///
  /// This initializer is particularly useful for creating KT1 wallets.
  ///
  /// - Parameters:
  ///   - address: The address of the originated account.
  ///   - keys: The keys of managing account.
  private init(address: String, keys: Keys, mnemonic: String? = nil) {
    self.keys = keys
    self.address = address
    self.mnemonic = mnemonic
  }
}

extension Wallet: Equatable {
  public static func == (lhs: Wallet, rhs: Wallet) -> Bool {
    return lhs.keys == rhs.keys
  }
}
