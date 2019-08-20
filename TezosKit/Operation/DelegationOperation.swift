// Copyright Keefer Taylor, 2018

import Foundation

/// An operation to set a delegate for an address.
public class DelegationOperation: AbstractOperation {
  // swiftlint:disable weak_delegate
  /// The address that will be set as the delegate.
  public let delegate: Address?
  // swiftlint:enable weak_delegate

  public override var dictionaryRepresentation: [String: Any] {
    var operation = super.dictionaryRepresentation
    if let delegate = self .delegate {
      operation["delegate"] = delegate
    }
    return operation
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
  ///   - operationFees: OperationFees for the transaction.
  internal init(source: Address, delegate: Address?, operationFees: OperationFees) {
    self.delegate = delegate
    super.init(source: source, kind: .delegation, operationFees: operationFees)
  }

  /// Register the given address as a delegate.
  /// - Parameters:
  ///   - source: The address that will register as a delegate.
  ///   - operationFees: OperationFees for the transaction.
  public static func registerDelegateOperation(
    source: Address,
    operationFees: OperationFees
  ) -> DelegationOperation {
    return  DelegationOperation(source: source, delegate: source, operationFees: operationFees)
  }

  /// Delegate to the given address.
  /// - Parameters:
  ///   - source: The address that will delegate funds.
  ///   - delegate: The address to delegate to.
  ///   - operationFees: OperationFees for the transaction.
  public static func delegateOperation(
    source: Address,
    to delegate: Address,
    operationFees: OperationFees
  ) -> DelegationOperation {
    return  DelegationOperation(source: source, delegate: delegate, operationFees: operationFees)
  }

  /// Clear the delegate from the given address.
  /// - Parameters:
  ///   - source: The address that will have its delegate cleared.
  ///   - operationFees: OperationFees for the transaction.
  public static func undelegateOperation(source: Address, operationFees: OperationFees) -> DelegationOperation {
    return DelegationOperation(source: source, delegate: nil, operationFees: operationFees)
  }

  public override func mutableCopy(with zone: NSZone? = nil) -> Any {
    return DelegationOperation(source: source, delegate: delegate, operationFees: operationFees)
  }
}
