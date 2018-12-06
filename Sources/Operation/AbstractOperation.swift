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
  public var requiresReveal: Bool {
    switch kind {
    case .delegation, .transaction, .origination:
      return true
    case .activateAccount, .reveal:
      return false
    }
  }

  public var dictionaryRepresentation: [String: String] {
    var operation: [String: String] = [:]
    operation["kind"] = kind.rawValue
    operation["source"] = source

    return operation
  }

  public init(source: String,
              kind: OperationKind) {
    self.source = source
    self.kind = kind
  }
}
