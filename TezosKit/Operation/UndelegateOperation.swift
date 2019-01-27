// Copyright Keefer Taylor, 2018

import Foundation

/** An operation to set a clear a delegate for an address. */
public class UndelegateOperation: AbstractOperation {
  public override var defaultFees: OperationFees {
    let fee = TezosBalance(balance: 0.001_257)
    let storageLimit = TezosBalance.zeroBalance
    let gasLimit = TezosBalance(balance: 0.010_000)
    return OperationFees(fee: fee, gasLimit: gasLimit, storageLimit: storageLimit)
  }

  /**
   * - Parameter source: The address that will delegate funds.
   * - Parameter operationFees: OperationFees for the transaction. If nil, default fees are used.
   */
  public init(source: String, operationFees: OperationFees? = nil) {
    super.init(source: source, kind: .delegation, operationFees: operationFees)
  }
}
