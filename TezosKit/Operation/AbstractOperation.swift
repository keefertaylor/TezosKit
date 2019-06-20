// Copyright Keefer Taylor, 2018

import Foundation

/// An abstract super class representing an operation to perform on the blockchain. Common parameters across operations
/// and default parameter values are provided by the abstract class's implementation.
public class AbstractOperation: Operation {
  public let source: String
  public let kind: OperationKind
  public let operationFees: OperationFees

  public var requiresReveal: Bool {
    switch kind {
    case .delegation, .transaction, .origination:
      return true
    case .reveal:
      return false
    }
  }

  public var dictionaryRepresentation: [String: Any] {
    var operation: [String: String] = [:]
    operation["kind"] = kind.rawValue
    operation["source"] = source

    operation["storage_limit"] = operationFees.storageLimit.rpcRepresentation
    operation["gas_limit"] = operationFees.gasLimit.rpcRepresentation
    operation["fee"] = operationFees.fee.rpcRepresentation

    return operation
  }

  public init(source: String, kind: OperationKind, operationFees: OperationFees) {
    self.source = source
    self.kind = kind
    self.operationFees = operationFees
  }
}
