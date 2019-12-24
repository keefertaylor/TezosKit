// Copyright Keefer Taylor, 2019.

import Foundation

/// An operation payload that is signed and bound to a specific protocol.
public struct SignedProtocolOperationPayload {
  /// Retrieve a dictionary representation of the payload.
  public var dictionaryRepresentation: [[String: Any]] {
    var payload = signedOperationPayload.dictionaryRepresentation
    payload["protocol"] = `protocol`
    return [payload]
  }

  /// An operation payload and associated signature.
  private let signedOperationPayload: SignedOperationPayload

  /// The hash of the protocol for the payload.
  private let `protocol`: String

  /// - Parameters:
  ///   - signedOperationPayload: An operation payload and associated signature.
  ///   - operationMetadata: Metadata for the operation.
  public init(signedOperationPayload: SignedOperationPayload, operationMetadata: OperationMetadata) {
    self.signedOperationPayload = signedOperationPayload
    self.protocol = operationMetadata.`protocol`
  }
}
