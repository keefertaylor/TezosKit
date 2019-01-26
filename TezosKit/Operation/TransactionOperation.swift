// Copyright Keefer Taylor, 2018

import Foundation

/** An operation to transact XTZ between addresses. */
public class TransactionOperation: AbstractOperation {
  private let amount: TezosBalance
  private let destination: String
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

  public override var defaultFees: OperationFees {
    let fee = TezosBalance(balance: 0.001272)
    let storageLimit = TezosBalance(balance: 0.000257)
    let gasLimit = TezosBalance(balance: 0.010100)
    return OperationFees(fee: fee, gasLimit: gasLimit, storageLimit: storageLimit)
  }

  /**
   * @param amount The amount of XTZ to transact.
   * @param source The wallet that is sending the XTZ.
   * @param to The address that is receiving the XTZ.
   * @param parameters Optional parameters to include in the transaction if the call is being made to a smart contract.
   * @param operationFees OperationFees for the transaction. If nil, default fees are used.
   */
  public convenience init(amount: TezosBalance, source: Wallet, destination: String, parameters _: [String: Any]? = nil, operationFees: OperationFees? = nil) {
    self.init(amount: amount, source: source.address, destination: destination, operationFees: operationFees)
  }

  /**
   * @param amount The amount of XTZ to transact.
   * @param from The address that is sending the XTZ.
   * @param to The address that is receiving the XTZ.
   * @param parameters Optional parameters to include in the transaction if the call is being made to a smart contract.
   * @param operationFees OperationFees for the transaction. If nil, default fees are used.
   */
  public init(amount: TezosBalance, source: String, destination: String, parameters: [String: Any]? = nil, operationFees: OperationFees? = nil) {
    self.amount = amount
    self.destination = destination
    self.parameters = parameters

    super.init(source: source, kind: .transaction, operationFees: operationFees)
  }
}
