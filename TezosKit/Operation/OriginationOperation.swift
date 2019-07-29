// Copyright Keefer Taylor, 2018

import Foundation

/// An operation that originates a new KT1 account.
public class OriginationOperation: AbstractOperation {
  private let managerPublicKeyHash: String

  public override var dictionaryRepresentation: [String: Any] {
    var operation = super.dictionaryRepresentation
    operation["balance"] = "0"
    operation["manager_pubkey"] = managerPublicKeyHash

    return operation
  }

  /// Create a new origination operation that will occur from the given address.
  ///
  /// - Parameters:
  ///   - wallet: The wallet which will originate the new account.
  ///   - operationFees: OperationFees for the transaction.
  public init(address: Address, operationFees: OperationFees) {
    managerPublicKeyHash = address

    super.init(source: address, kind: .origination, operationFees: operationFees)
  }
}
