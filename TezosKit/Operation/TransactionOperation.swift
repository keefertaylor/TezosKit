// Copyright Keefer Taylor, 2018

import Foundation

/// An operation to transact XTZ between addresses.
public class TransactionOperation: AbstractOperation {
  private let amount: Tez
  private let destination: Address
  private let parameters: [String: Any]?

  public override var dictionaryRepresentation: [String: Any] {
    var operation = super.dictionaryRepresentation
    operation["amount"] = amount.rpcRepresentation
    operation["destination"] = destination
    if let parameters = self.parameters {
      operation["parameters"] = parameters
    }

    return operation
  }

  /// - Parameters:
  ///   - amount: The amount of XTZ to transact.
  ///   - from: The address that is sending the XTZ.
  ///   - to: The address that is receiving the XTZ.
  ///   - parameters: Optional parameters to include in the transaction if the call is being made to a smart contract.
  ///   - operationFees: OperationFees for the transaction.
  public init(
    amount: Tez,
    source: Address,
    destination: Address,
    parameters: [String: Any]? = nil,
    operationFees: OperationFees
  ) {
    self.amount = amount
    self.destination = destination
    self.parameters = parameters

    super.init(source: source, kind: .transaction, operationFees: operationFees)
  }
}
