// Copyright Keefer Taylor, 2018

import Foundation

/** An operation that originates a new KT1 account. */
public class OriginateAccountOperation: AbstractOperation {
  private let managerPublicKeyHash: String
  private let contractCode: ContractCode?

  public override var dictionaryRepresentation: [String: Any] {
    var operation = super.dictionaryRepresentation
    operation["balance"] = "0"
    operation["managerPubkey"] = managerPublicKeyHash

    if let contractCode = self.contractCode {
      operation["script"] = [
        "code": contractCode.code,
        "storage": contractCode.storage
      ]
    }

    return operation
  }

  public override var defaultFees: OperationFees {
    // TODO: Fix me!
    let fee = Tez(0.001_285)
    let storageLimit = Tez(0.06)
    let gasLimit = Tez(0.4)
    return OperationFees(fee: fee, gasLimit: gasLimit, storageLimit: storageLimit)
  }

  /**
   * Create a new origination operation that will occur from the given wallet's address.
   *
   * - Parameter wallet: The wallet which will originate the new account.
   * - Parameter contractCode: Optional code to associate with the originated contract.
   * - Parameter operationFees: OperationFees for the transaction. If nil, default fees are used.
   */
  public convenience init(wallet: Wallet, contractCode: ContractCode? = nil, operationFees: OperationFees? = nil) {
    self.init(address: wallet.address, contractCode: contractCode, operationFees: operationFees)
  }

  /** Create a new origination operation that will occur from the given address.
   *
   * - Parameter wallet: The wallet which will originate the new account.
   * - Parameter contractCode: Optional code to associate with the originated contract.
   * - Parameter operationFees: OperationFees for the transaction. If nil, default fees are used.
   */
  public init(address: String, contractCode: ContractCode? = nil, operationFees: OperationFees? = nil) {
    managerPublicKeyHash = address
    self.contractCode = contractCode

    super.init(source: address, kind: .origination, operationFees: operationFees)
  }
}
