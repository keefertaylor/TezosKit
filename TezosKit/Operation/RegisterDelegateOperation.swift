// Copyright Keefer Taylor, 2018

import Foundation

/** An operation to set a register and address as a delegate. */
public class RegisterDelegateOperation: AbstractOperation {
  // swiftlint:disable weak_delegate
  /** The address that will be set as the delegate. */
  public let delegate: String
  // swiftlint:enable weak_delegate

  public override var dictionaryRepresentation: [String: Any] {
    var operation = super.dictionaryRepresentation
    operation["delegate"] = delegate
    return operation
  }

  public override var defaultFees: OperationFees {
    let fee = Tez(0.001_257)
    let storageLimit = Tez.zeroBalance
    let gasLimit = Tez(0.010_000)
    return OperationFees(fee: fee, gasLimit: gasLimit, storageLimit: storageLimit)
  }

  /**
   * - Parameter delegate: The address will register as a delegate.
   * - Parameter operationFees: OperationFees for the transaction. If nil, default fees are used.
   */
  public init(delegate: String, operationFees: OperationFees? = nil) {
    self.delegate = delegate
    super.init(source: delegate, kind: .delegation, operationFees: operationFees)
  }
}
