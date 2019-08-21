// Copyright Keefer Taylor, 2019.

import Foundation

/// A payload that can be forged into operation bytes.
public struct OperationPayload {
  /// An array of dictionaries representing operations.
  internal let operations: [OperationWithCounter]

  /// The hash of the head of the chain to apply the operation on.
  internal let branch: String

  /// Retrieve a dictionary representation of the payload.
  public var dictionaryRepresentation: [String: Any] {
    var contents: [[String: Any]] = []
    for operation in operations {
      contents.append(operation.dictionaryRepresentation)
    }
    return [
      "contents": contents,
      "branch": branch
    ]
  }

  /// Creates a operation payload from a list of operations.
  ///
  /// This initializer will automatically add reveal operations and set address counters properly.
  ///
  /// - Parameters:
  ///   - operations: A list of operations to forge.
  ///   - operationMetadata: Metadata about the operations.
  public init(
    operations: [OperationWithCounter],
    operationMetadata: OperationMetadata
  ) {
    self.operations = operations
    self.branch = operationMetadata.branch
  }
}
