// Copyright Keefer Taylor, 2018

import Foundation

/** An operation to set a clear a delegate for an address. */
public class UndelegateOperation: AbstractOperation {
  public override var defaultFees: OperationFees {
    let fee = TezosBalance(balance: 0.001257)
    let storageLimit = TezosBalance.zeroBalance
    let gasLimit = TezosBalance(balance: 0.010000)
    return OperationFees(fee: fee, gasLimit: gasLimit, storageLimit: storageLimit)
  }

  /**
   * @param source The address that will delegate funds.
   * @param operationFees OperationFees for the transaction. If nil, default fees are used.
   */
  public init(source: String, operationFees: OperationFees? = nil) {
    super.init(source: source, kind: .delegation, operationFees: operationFees)
  }
}
