// Copyright Keefer Taylor, 2019.

import Foundation

/// A payload for an operation and associated signature.
public struct SignedOperationPayload {
  /// The operation payload.
  private let operationPayload: OperationPayload

  /// The signature for the operation payload.
  private let signature: String

  /// Retrieve a dictionary representation of the payload.
  public var dictionaryRepresentation: [String: Any] {
    var payload = operationPayload.dictionaryRepresentation
    payload["signature"] = signature
    return payload
  }

  /// - Parameters:
  ///   - operationPayload: The operation payload.
  ///   - signature: The signature for the operation payload.
  public init(operationPayload: OperationPayload, signature: String) {
    self.operationPayload = operationPayload
    self.signature = signature
  }
}
