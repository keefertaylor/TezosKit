// Copyright Keefer Taylor, 2019.

import Foundation

/// An operation which wraps an operation with an address counter for that operation.
public struct OperationWithCounter {
  /// The internal operation.
  internal let operation: Operation

  /// The address counter for the internal operation.
  internal let counter: Int

  public var dictionaryRepresentation: [String: Any] {
    var operationDict = operation.dictionaryRepresentation
    operationDict["counter"] = String(counter)
    return operationDict
  }

  public init(operation: Operation, counter: Int) {
    self.operation = operation
    self.counter = counter
  }
}
