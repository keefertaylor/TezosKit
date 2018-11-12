// Copyright Keefer Taylor, 2018

import Foundation

/** An operation to transact XTZ between addresses. */
public class TransactionOperation: AbstractOperation {
  private let amount: TezosBalance
  private let destination: String

  public override var dictionaryRepresentation: [String: String] {
    var operation = super.dictionaryRepresentation
    operation["amount"] = amount.rpcRepresentation
    operation["destination"] = destination

    return operation
  }

  /**
   * @param amount The amount of XTZ to transact.
   * @param source The wallet that is sending the XTZ.
   * @param to The address that is receiving the XTZ.
   */
  public convenience init(amount: TezosBalance, source: Wallet, destination: String) {
    self.init(amount: amount, source: source.address, destination: destination)
  }

  /**
   * @param amount The amount of XTZ to transact.
   * @param from The address that is sending the XTZ.
   * @param to The address that is receiving the XTZ.
   */
  public init(amount: TezosBalance, source: String, destination: String) {
    self.amount = amount
    self.destination = destination

    super.init(source: source, kind: .transaction)
  }
}
