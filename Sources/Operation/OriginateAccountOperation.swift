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
    return OperationFees(fee: fee, gasLimit: gasLimit, storageLimit: storageLimit)
  }

  /**
   * Create a new origination operation that will occur from the given wallet's address.
   *
   * @param wallet The wallet which will originate the new account.
   * @param operationFees OperationFees for the transaction. If nil, default fees are used.
   */
  public convenience init(wallet: Wallet, operationFees: OperationFees? = nil) {
    self.init(address: wallet.address, operationFees: operationFees)
  }

  /** Create a new origination operation that will occur from the given address.
   *
   * @param wallet The wallet which will originate the new account.
   * @param operationFees OperationFees for the transaction. If nil, default fees are used.
   */
  public init(address: String, operationFees: OperationFees? = nil) {
    managerPublicKeyHash = address
    super.init(source: address, kind: .origination, operationFees: operationFees)
  }
}
