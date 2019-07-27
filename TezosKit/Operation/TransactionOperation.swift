// Copyright Keefer Taylor, 2018

import Foundation

/// An operation to transact XTZ between addresses.
public class TransactionOperation: AbstractOperation {
  private let amount: Tez
  private let destination: Address
  private let micheline: [Micheline]?

  public override var dictionaryRepresentation: [String: Any] {
    var operation = super.dictionaryRepresentation
    operation["amount"] = amount.rpcRepresentation
    operation["destination"] = destination
    if let micheline = self.micheline {
      let dict: [[String: Any]] = micheline.map { $0.json }
      guard let json = JSONUtils.jsonString(for: dict) else {
        print("Flagrant error")
        return ["WRONG": "WRONG"]
      }
      operation["parameters"] = json
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
    parameters: [Micheline]? = nil,
    operationFees: OperationFees
  ) {
    self.amount = amount
    self.destination = destination
    self.micheline = parameters

    super.init(source: source, kind: .transaction, operationFees: operationFees)
  }
}
