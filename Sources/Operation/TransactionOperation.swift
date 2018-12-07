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

  /**
   * @param amount The amount of XTZ to transact.
   * @param source The wallet that is sending the XTZ.
   * @param to The address that is receiving the XTZ.
   * @param parameters Optional parameters to include in the transaction if the call is being made to a smart contract.
   */
  public convenience init(amount: TezosBalance, source: Wallet, destination: String, parameters: [String: Any]? = nil) {
    self.init(amount: amount, source: source.address, destination: destination, parameters: parameters)
  }

  /**
   * @param amount The amount of XTZ to transact.
   * @param from The address that is sending the XTZ.
   * @param to The address that is receiving the XTZ.
   * @param parameters Optional parameters to include in the transaction if the call is being made to a smart contract.
   */
  public init(amount: TezosBalance, source: String, destination: String, parameters: [String: Any]? = nil) {
    self.amount = amount
    self.destination = destination
    self.parameters = parameters

    super.init(source: source, kind: .transaction)
  }
}
