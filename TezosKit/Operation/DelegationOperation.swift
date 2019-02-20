// Copyright Keefer Taylor, 2018

import Foundation

/** An operation to set a delegate for an address. */
public class DelegationOperation: AbstractOperation {
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
   * - Parameter source: The address that will delegate funds.
   * - Parameter delegate: The address to delegate to.
   * - Parameter operationFees: OperationFees for the transaction. If nil, default fees are used.
   */
  public init(source: String, to delegate: String, operationFees: OperationFees? = nil) {
    self.delegate = delegate
    super.init(source: source, kind: .delegation, operationFees: operationFees)
  }
}
