// Copyright Keefer Taylor, 2018

import Foundation

/** An operation to set a register and address as a delegate. */
public class RegisterDelegateOperation: AbstractOperation {
  /** The address that will be set as the delegate. */
  public let delegate: String

  public override var dictionaryRepresentation: [String: Any] {
    var operation = super.dictionaryRepresentation
    operation["delegate"] = delegate
    return operation
  }

  public override var defaultFees: OperationFees {
    let fee = TezosBalance(balance: 0.001257)
    let storageLimit = TezosBalance.zeroBalance
    let gasLimit = TezosBalance(balance: 0.010000)
    return OperationFees(fee: fee, gasLimit: gasLimit, storageLimit: storageLimit)
  }

  /**
   * @param delegate The address will register as a delegate.
   * @param operationFees OperationFees for the transaction. If nil, default fees are used.
   */
  public init(delegate: String, operationFees: OperationFees? = nil) {
    self.delegate = delegate
    super.init(source: delegate, kind: .delegation, operationFees: operationFees)
  }
}
