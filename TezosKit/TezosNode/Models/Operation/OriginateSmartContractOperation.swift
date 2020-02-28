//
//  OriginateSmartContractOperation.swift
//  TezosKit
//
//  Created by Simon Mcloughlin on 28/02/2020.
//

import Foundation

/// An operation to transact XTZ between addresses.
public class OriginateSmartContractOperation: AbstractOperation {
  private enum JSON {
    public enum Keys {
      public static let balance = "balance"
      public static let michelineInit = "init"
      public static let code = "code"
      public static let storage = "storage"
      public static let script = "script"
    }
  }

  internal let michelineInit: [String: Any]
  internal let code: Any

  public override var dictionaryRepresentation: [String: Any] {
    var operation = super.dictionaryRepresentation
    operation[OriginateSmartContractOperation.JSON.Keys.balance] = "0"

    let script = [OriginateSmartContractOperation.JSON.Keys.code: code, OriginateSmartContractOperation.JSON.Keys.storage: michelineInit]
    operation[OriginateSmartContractOperation.JSON.Keys.script] = script

    return operation
  }

  /// - Parameters:
  ///   - michelineInit: Micheline JSON object used to initialize storage
  ///   - code: Micheline object containing the complied Michelon smart contract code
  ///   - operationFees: OperationFees for the transaction.
  public init(
    michelineInit: [String: Any],
    code: Any,
    source: Address,
    operationFees: OperationFees
  ) {
    self.michelineInit = michelineInit
    self.code = code

    super.init(source: source, kind: .origination, operationFees: operationFees)
  }

  public override func mutableCopy(with zone: NSZone? = nil) -> Any {
    return OriginateSmartContractOperation(
      michelineInit: michelineInit,
      code: code,
      source: source,
      operationFees: operationFees
    )
  }
}
