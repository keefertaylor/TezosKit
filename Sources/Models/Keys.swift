// Copyright Keefer Taylor, 2018

import Foundation

/** A structure representing public and private keys for a wallet in the Tezos ecosystem. */
public struct Keys {
  /** A base58check encoded public key for the wallet, prefixed with "edpk". */
  public let publicKey: String

  /** A base58check encoded secret key for the wallet, prefixed with "edsk". */
  public let secretKey: String
}

extension Keys: Equatable {
  public static func == (lhs: Keys, rhs: Keys) -> Bool {
    return lhs.publicKey == rhs.publicKey && lhs.secretKey == rhs.secretKey
  }
}
