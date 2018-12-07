// Copyright Keefer Taylor, 2018

import Foundation

/**
 * An abstract super class representing an operation to perform on the blockchain. Common parameters
 * across operations and default parameter values are provided by the abstract class's
 * implementation.
 */
public class AbstractOperation: Operation {
  public let source: String
  public let kind: OperationKind
  public let operationFees: OperationFees?

  public var requiresReveal: Bool {
    switch kind {
    case .delegation, .transaction, .origination:
      return true
    case .activateAccount, .reveal:
      return false
    }
  }

  public var dictionaryRepresentation: [String: Any] {
    var operation: [String: String] = [:]
    operation["kind"] = kind.rawValue
    operation["source"] = source

    let operationFee = self.operationFees ?? self.defaultFees
    operation["storage_limit"] = operationFee.storageLimit.rpcRepresentation
    operation["gas_limit"] = operationFee.gasLimit.rpcRepresentation
    operation["fee"] = operationFee.fee.rpcRepresentation

    return operation
  }

  public var defaultFees: OperationFees {
    return OperationFees(fee: TezosBalance.zeroBalance,
                         gasLimit: TezosBalance.zeroBalance,
                         storageLimit: TezosBalance.zeroBalance)
  }

  public init(source: String,
              kind: OperationKind,
              operationFees: OperationFees? = nil) {
    self.source = source
    self.kind = kind

    self.operationFees = operationFees
  }
}
