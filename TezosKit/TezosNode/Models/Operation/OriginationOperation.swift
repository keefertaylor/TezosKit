//
//  OriginationOperation.swift
//  TezosKit
//
//  Created by Simon Mcloughlin on 28/02/2020.
//

import Foundation

/// An operation to transact XTZ between addresses.
public class OriginationOperation: AbstractOperation {
  private enum JSON {
    public enum Keys {
      public static let balance = "balance"
      public static let code = "code"
      public static let storage = "storage"
      public static let script = "script"
    }
  }

  internal let balance: Tez
  internal let code: MichelsonParameter
  internal let storage: MichelsonParameter

  public override var dictionaryRepresentation: [String: Any] {
    var operation = super.dictionaryRepresentation
    operation[JSON.Keys.balance] = balance.rpcRepresentation
    operation[JSON.Keys.script] = [
      JSON.Keys.code: code.networkRepresentation,
      JSON.Keys.storage: storage.networkRepresentation
    ]

    return operation
  }

  /// - Parameters:
  ///   - source: The address originating the contract
  ///   - balance: The amount of XTZ to move to the new contract.
  ///   - code: Michelson parameters which make up code for the contract
  ///   - storage: Initial storage for the contract
  ///   - operationFees: OperationFees for the transaction.
  public init(
    source: Address,
    balance: Tez,
    code: MichelsonParameter,
    storage: MichelsonParameter,
    operationFees: OperationFees
  ) {
    self.balance = balance
    self.code = code
    self.storage = storage

    super.init(source: source, kind: .origination, operationFees: operationFees)
  }

  public override func mutableCopy(with zone: NSZone? = nil) -> Any {
    return OriginationOperation(
      source: source,
      balance: balance,
      code: code,
      storage: storage,
      operationFees: operationFees
    )
  }
}
