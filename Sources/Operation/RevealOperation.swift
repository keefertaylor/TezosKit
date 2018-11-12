// Copyright Keefer Taylor, 2018

import Foundation

/**
 * An operation to reveal an address.
 *
 * Note that TezosKit will automatically inject this operation when required for supported
 * operations.
 */
public class RevealOperation: AbstractOperation {
  public override var dictionaryRepresentation: [String: String] {
    var operation = super.dictionaryRepresentation
    operation["public_key"] = publicKey
    return operation
  }

  /** The public key for the address being revealed. */
  public let publicKey: String

  /**
   * Initialize a new reveal operation for the given wallet.
   *
   * @param wallet The wallet that will be revealed.
   */
  public convenience init(from wallet: Wallet) {
    self.init(from: wallet.address, publicKey: wallet.keys.publicKey)
  }

  /**
   * Initialize a new reveal operation.
   *
   * @param address The address to reveal.
   * @param publicKey The public key of the address to reveal.
   */
  public init(from address: String, publicKey: String) {
    self.publicKey = publicKey
    super.init(source: address,
               kind: .reveal,
               fee: AbstractOperation.zeroTezosBalance,
               gasLimit: AbstractOperation.zeroTezosBalance,
               storageLimit: AbstractOperation.zeroTezosBalance)
  }
}
