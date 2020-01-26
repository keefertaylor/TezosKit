// Copyright Keefer Taylor, 2018

import Foundation

/// A model of a wallet in the Tezos ecosystem.
///
/// Clients can create a new wallet by calling the empty initializer. Clients can also restore an existing wallet by
/// providing an mnemonic and optional passphrase.
public struct Wallet {
  /// Keys for the wallet.
  public let publicKey: PublicKeyProtocol
  internal let secretKey: SecretKey

  /// A base58check encoded public key hash for the wallet, prefixed with "tz1" which represents an address in the Tezos
  /// ecosystem.
  public let address: Address

  /// If this wallet was gnerated from a mnemonic, a space delimited string of english mnemonic words
  /// used to generate the wallet with the BIP39 specification, otherwise nil.
  public let mnemonic: String?

  /// Create a new wallet by generating a mnemonic and encrypted with an optional passphrase.
  ///
  ///- Parameter
  ///   - passphrase: An optional passphrase used for encryption.
  ///   - signingCurve: The curve to use. Default is ed25519.
  public init?(passphrase: String = "", signingCurve: EllipticalCurve = .ed25519) {
    guard let mnemonic = MnemonicUtil.generateMnemonic() else {
      return nil
    }
    self.init(mnemonic: mnemonic, passphrase: passphrase, signingCurve: signingCurve)
  }

  /// Create a new wallet with the given mnemonic and encrypted with an optional passphrase.
  ///
  /// - Parameters:
  ///   - mnemonic: A space delimited string of english mnemonic words from the BIP39
  ///   - passphrase: An optional passphrase used for encryption.
  ///   - signingCurve: The curve to use. Default is ed25519.
  public init?(mnemonic: String, passphrase: String = "", signingCurve: EllipticalCurve = .ed25519) {
    guard
      let seedString = MnemonicUtil.seedString(from: mnemonic, passphrase: passphrase),
      let secretKey = SecretKey(seedString: seedString, signingCurve: signingCurve),
      let publicKey = PublicKey(secretKey: secretKey)
    else {
      return nil
    }

    let address = publicKey.publicKeyHash
    self.init(address: address, publicKey: publicKey, secretKey: secretKey, mnemonic: mnemonic)
  }

  /// Create a wallet with a given secret key.
  ///
  /// - Parameter
  ///   - secretKey: A base58check encoded secret key, prefixed with "edsk".
  ///   - signingCurve: The curve to use. Default is ed25519.
  public init?(secretKey: String, signingCurve: EllipticalCurve = .ed25519) {
    guard
      let secretKey = SecretKey(secretKey, signingCurve: signingCurve),
      let publicKey = PublicKey(secretKey: secretKey)
    else {
      return nil
    }

    let address = publicKey.publicKeyHash
    self.init(address: address, publicKey: publicKey, secretKey: secretKey)
  }

  /// Create a wallet with the given address and keys.
  ///
  /// This initializer is particularly useful for creating KT1 wallets.
  ///
  /// - Parameters:
  ///   - address: The address of the originated account.
  ///   - publicKey: The public key.
  ///   - secretKey: The secret key.
  ///   - mnemonic: An optional mnemonic used to generate the wallet.
  private init(address: Address, publicKey: PublicKey, secretKey: SecretKey, mnemonic: String? = nil) {
    self.secretKey = secretKey
    self.publicKey = publicKey
    self.address = address
    self.mnemonic = mnemonic
  }
}

extension Wallet: Equatable {
  public static func == (lhs: Wallet, rhs: Wallet) -> Bool {
    return lhs.publicKey.base58CheckRepresentation == rhs.publicKey.base58CheckRepresentation &&
      lhs.secretKey == rhs.secretKey
  }
}

extension Wallet: SignatureProvider {
  public func sign(_ hex: String) -> [UInt8]? {
    return secretKey.sign(hex: hex)
  }
}
