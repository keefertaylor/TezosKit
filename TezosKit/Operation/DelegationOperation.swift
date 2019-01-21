// Copyright Keefer Taylor, 2018

import Foundation

/** An operation to set a delegate for an address. */
public class DelegationOperation: AbstractOperation {
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
   * @param source The address that will delegate funds.
   * @param delegate The address to delegate to.
   * @param operationFees OperationFees for the transaction. If nil, default fees are used.
   */
  public init(source: String, to delegate: String, operationFees: OperationFees? = nil) {
    self.delegate = delegate
    super.init(source: source, kind: .delegation, operationFees: operationFees)
  }
}
