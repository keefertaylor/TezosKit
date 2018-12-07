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
        "storage": contractCode.storage,
      ]
    }

    return operation
  }

  /**
   * Create a new origination operation that will occur from the given wallet's address.
   *
   * @param wallet The wallet originating the transaction.
   * @param contractCode Optional code to associate with the originated contract.
   */
  public convenience init(wallet: Wallet, contractCode _: ContractCode? = nil) {
    self.init(address: wallet.address)
  }

  /**
   * Create a new origination operation that will occur from the given address.
   *
   * @param address The address originating the transaction.
   * @param contractCode Optional code to associate with the originated contract.
   */
  public init(address: String, contractCode: ContractCode? = nil) {
    managerPublicKeyHash = address
    self.contractCode = contractCode

    let fee = TezosBalance(balance: 0.101385)
    let gasLimit = TezosBalance(balance: 0.010000)
    let storageLimit = TezosBalance(balance: 0.01)

    super.init(source: address,
               kind: .origination,
               fee: fee,
               gasLimit: gasLimit,
               storageLimit: storageLimit)
  }
}
