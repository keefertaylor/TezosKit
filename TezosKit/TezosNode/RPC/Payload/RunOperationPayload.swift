// Copyright Keefer Taylor, 2019.

import Foundation

/// A payload for an running an operation.
public struct RunOperationPayload {
  private enum JSON {
    public static let chainID = "chain_id"
    public static let operation = "operation"
  }

  /// The operation payload.
  private let signedOperationPayload: SignedOperationPayload

  /// The Chain ID to run on.
  private let chainID: String

  /// Retrieve a dictionary representation of the payload.
  public var dictionaryRepresentation: [String: Any] {
    return [
      JSON.operation: signedOperationPayload.dictionaryRepresentation,
      JSON.chainID: chainID
    ]
  }

  /// - Parameters:
  ///   - signedOperationPayload: The `SignedOperationPayload`
  ///   - operationMetadata: The `OperationMetadata`.
  public init(signedOperationPayload: SignedOperationPayload, operationMetadata: OperationMetadata) {
    self.signedOperationPayload = signedOperationPayload
    self.chainID = operationMetadata.chainID
  }
}
