// Copyright Keefer Taylor, 2018

import Foundation

/// An operation to set a delegate for an address.
public class DelegationOperation: AbstractOperation {
  // swiftlint:disable weak_delegate
  /// The address that will be set as the delegate.
  public let delegate: String?
  // swiftlint:enable weak_delegate

  public override var dictionaryRepresentation: [String: Any] {
    var operation = super.dictionaryRepresentation
    if let delegate = self .delegate {
      operation["delegate"] = delegate
    }
    return operation
  }

  public override var defaultFees: OperationFees {
    let fee = Tez(0.001_257)
    let storageLimit = Tez.zeroBalance
    let gasLimit = Tez(0.010_000)
    return OperationFees(fee: fee, gasLimit: gasLimit, storageLimit: storageLimit)
  }

  /// Create a delegation operation.
  ///
  /// If delegate and source are the same, then the source will be registered as a delegate.
  /// If delegate and source are different, then source will delegate to delegate.
  /// If delegate is nil, source will clear any delegation.
  ///
  /// - Parameters:
  ///   - source: The address that will delegate funds.
  ///   - delegate: The address to delegate to.
  ///   - operationFees: OperationFees for the transaction. If nil, default fees are used.
  internal init(source: String, delegate: String?, operationFees: OperationFees?  = nil) {
    self.delegate = delegate
    super.init(source: source, kind: .delegation, operationFees: operationFees)
  }

  /// Register the given address as a delegate.
  /// - Parameters:
  ///   - source: The address that will register as a delegate.
  ///   - operationFees: OperationFees for the transaction. If nil, default fees are used.
  public static func registerDelegateOperation(
    source: String,
    operationFees: OperationFees?  = nil
  ) -> DelegationOperation {
    return  DelegationOperation(source: source, delegate: source, operationFees: operationFees)
  }

  /// Delegate to the given address.
  /// - Parameters:
  ///   - source: The address that will delegate funds.
  ///   - delegate: The address to delegate to.
  ///   - operationFees: OperationFees for the transaction. If nil, default fees are used.
  public static func delegateOperation(
    source: String,
    to delegate: String,
    operationFees: OperationFees? = nil
  ) -> DelegationOperation {
    return  DelegationOperation(source: source, delegate: delegate, operationFees: operationFees)
  }

  /// Clear the delegate from the given address.
  /// - Parameters:
  ///   - source: The address that will have its delegate cleared.
  ///   - operationFees: OperationFees for the transaction. If nil, default fees are used.
  public static func undelegateOperation(source: String, operationFees: OperationFees? = nil) -> DelegationOperation {
    return DelegationOperation(source: source, delegate: nil, operationFees: operationFees)
  }
}
