// Copyright Keefer Taylor, 2019.

import Foundation

/// A payload that can be forged into operation bytes.
public struct OperationPayload {
  /// An array of dictionaries representing operations.
  private let contents: [[String: Any]]

  /// The hash of the head of the chain to apply the operation on.
  private let branch: String

  /// Retrieve a dictionary representation of the payload.
  public var dictionaryRepresentation: [String: Any] {
    return [
      "contents": contents,
      "branch": branch
    ]
  }

  /// - Parameters:
  ///   - contents: An array of dictionaries representing operations.
  ///   - operationMetadata: Metadata to include in the operations.
  public init(contents: [[String: Any]], operationMetadata: OperationMetadata) {
    self.contents = contents
    self.branch = operationMetadata.branch
  }
}