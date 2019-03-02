// Copyright Keefer Taylor, 2019.

import Foundation

/// A payload that can be forged into operation bytes.
public struct OperationPayload {
  /// An array of dictionaries representing operations.
  private let operations: [OperationWithCounter]

  /// The hash of the head of the chain to apply the operation on.
  private let branch: String

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

  /// - Parameters:
  ///   - operations: A list of operations to send in the payload.
  ///   - operationMetadata: Metadata to include in the operations.
  public init(operations: [OperationWithCounter], operationMetadata: OperationMetadata) {
    self.operations = operations
    self.branch = operationMetadata.branch
  }
}
