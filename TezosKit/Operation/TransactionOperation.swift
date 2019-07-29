// Copyright Keefer Taylor, 2018

import Foundation

/// An operation to transact XTZ between addresses.
public class TransactionOperation: AbstractOperation {
  private let amount: Tez
  private let destination: Address
  private let parameter: MichelsonParameter?

  public override var dictionaryRepresentation: [String: Any] {
    var operation = super.dictionaryRepresentation
    operation["amount"] = amount.rpcRepresentation
    operation["destination"] = destination
    if let parameter = self.parameter {
        operation["parameters"] = parameter.networkRepresentation
    }
    return operation
  }

  /// - Parameters:
  ///   - amount: The amount of XTZ to transact.
  ///   - parameter: An optional parameter to include in the transaction if the call is being made to a smart contract.
  ///   - from: The address that is sending the XTZ.
  ///   - to: The address that is receiving the XTZ.
  ///   - operationFees: OperationFees for the transaction.
  public init(
    amount: Tez,
    parameter: MichelsonParameter? = nil,
    source: Address,
    destination: Address,
    operationFees: OperationFees
  ) {
    self.amount = amount
    self.destination = destination
    self.parameter = parameter

    super.init(source: source, kind: .transaction, operationFees: operationFees)
  }
}
