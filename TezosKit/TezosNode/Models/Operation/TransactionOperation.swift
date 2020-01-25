// Copyright Keefer Taylor, 2018

import Foundation

/// An operation to transact XTZ between addresses.
public class TransactionOperation: AbstractOperation {
  private enum JSON {
    public enum Keys {
      public static let amount = "amount"
      public static let destination = "destination"
      public static let value = "value"
    }
  }

  internal let amount: Tez
  internal let destination: Address

  public override var dictionaryRepresentation: [String: Any] {
    var operation = super.dictionaryRepresentation
    operation[TransactionOperation.JSON.Keys.amount] = amount.rpcRepresentation
    operation[TransactionOperation.JSON.Keys.destination] = destination

    return operation
  }

  /// - Parameters:
  ///   - amount: The amount of XTZ to transact.
  ///   - from: The address that is sending the XTZ.
  ///   - to: The address that is receiving the XTZ.
  ///   - operationFees: OperationFees for the transaction.
  public init(
    amount: Tez,
    source: Address,
    destination: Address,
    operationFees: OperationFees
  ) {
    self.amount = amount
    self.destination = destination

    super.init(source: source, kind: .transaction, operationFees: operationFees)
  }

  public override func mutableCopy(with zone: NSZone? = nil) -> Any {
    return TransactionOperation(
      amount: amount,
      source: source,
      destination: destination,
      operationFees: operationFees
    )
  }
}
