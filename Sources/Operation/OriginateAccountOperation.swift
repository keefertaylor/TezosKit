// Copyright Keefer Taylor, 2018

import Foundation

/** An operation that originates a new KT1 account. */
public class OriginateAccountOperation: AbstractOperation {
  let managerPublicKeyHash: String

  public override var dictionaryRepresentation: [String: Any] {
    var operation = super.dictionaryRepresentation
    operation["balance"] = "0"
    operation["managerPubkey"] = managerPublicKeyHash
    return operation
  }

  /**
   * Create a new origination operation that will occur from the given wallet's address.
   *
   * @param wallet The wallet originating the transaction.
   */
  public convenience init(wallet: Wallet) {
    self.init(address: wallet.address)
  }

  /**
   * Create a new origination operation that will occur from the given address.
   *
   * @param address The address originating the transaction.
   */
  public init(address: String) {
    managerPublicKeyHash = address

    let fee = TezosBalance(balance: 0.001285)
    let gasLimit = TezosBalance(balance: 0.010000)
    let storageLimit = TezosBalance(balance: 0.000257)

    super.init(source: address,
               kind: .origination,
               fee: fee,
               gasLimit: gasLimit,
               storageLimit: storageLimit)
  }
}
