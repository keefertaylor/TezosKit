// Copyright Keefer Taylor, 2018

import Foundation

/// An abstract super class representing an operation to perform on the blockchain. Common parameters across operations
/// and default parameter values are provided by the abstract class's implementation.
public class AbstractOperation: Operation {
  public let source: Address
  public let kind: OperationKind
  public var operationFees: OperationFees

  public var requiresReveal: Bool {
    switch kind {
    case .delegation, .transaction:
      return true
    case .reveal:
      return false
    }
  }

  public var dictionaryRepresentation: [String: Any] {
    var operation: [String: String] = [:]
    operation["kind"] = kind.rawValue
    operation["source"] = source

    operation["storage_limit"] = String(operationFees.storageLimit)
    operation["gas_limit"] = String(operationFees.gasLimit)
    operation["fee"] = operationFees.fee.rpcRepresentation

    return operation
  }

  public init(source: Address, kind: OperationKind, operationFees: OperationFees) {
    self.source = source
    self.kind = kind
    self.operationFees = operationFees
  }
}

extension AbstractOperation: NSMutableCopying {
  public func mutableCopy(with zone: NSZone? = nil) -> Any {
    return AbstractOperation(source: source, kind: kind, operationFees: operationFees)
  }
}
