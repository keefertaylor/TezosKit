// Copyright Keefer Taylor, 2018

import Foundation

/** An operation that originates a new KT1 account. */
public class OriginateAccountOperation: AbstractOperation {
  let managerPublicKeyHash: String

  public override var dictionaryRepresentation: [String: String] {
    var operation = super.dictionaryRepresentation
    operation["balance"] = "0"
    operation["managerPubkey"] = managerPublicKeyHash

    return operation
  }

  public override var defaultFees: OperationFees {
    let fee = TezosBalance(balance: 0.001285)
    let storageLimit = TezosBalance(balance: 0.000257)
    let gasLimit = TezosBalance(balance: 0.010000)
    return OperationFees(fee: fee,  gasLimit: gasLimit, storageLimit: storageLimit)
  }

  /** Create a new origination operation that will occur from the given wallet's address. */
  public convenience init(wallet: Wallet) {
    self.init(address: wallet.address)
  }

  /** Create a new origination operation that will occur from the given address. */
  public init(address: String) {
    managerPublicKeyHash = address
    super.init(source: address, kind: .origination)
  }
}
