// Copyright Keefer Taylor, 2018

import Foundation

/// An operation that originates a new KT1 account.
/// TODO: Rebase to `OriginateOperation`
public class OriginateAccountOperation: AbstractOperation {
  private let managerPublicKeyHash: String
  private let contractCode: ContractCode?

  public override var dictionaryRepresentation: [String: Any] {
    var operation = super.dictionaryRepresentation
    operation["balance"] = "0"
    operation["manager_pubkey"] = managerPublicKeyHash

    if let contractCode = self.contractCode {
      operation["script"] = [
        "code": contractCode.code,
        "storage": contractCode.storage
      ]
    }

    return operation
  }

  /// Create a new origination operation that will occur from the given address.
  ///
  /// - Parameters:
  ///   - wallet: The wallet which will originate the new account.
  ///   - contractCode: Optional code to associate with the originated contract.
  ///   - operationFees: OperationFees for the transaction.
  public init(address: String, contractCode: ContractCode? = nil, operationFees: OperationFees) {
    managerPublicKeyHash = address
    self.contractCode = contractCode

    super.init(source: address, kind: .origination, operationFees: operationFees)
  }
}
