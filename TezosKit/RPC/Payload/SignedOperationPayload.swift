// Copyright Keefer Taylor, 2019.

import Foundation
import TezosCrypto

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
  ///   - operationSigningResult: The operation signing result from the signing the given payload.
  public init(operationPayload: OperationPayload, operationSigningResult: OperationSigningResult) {
    self.operationPayload = operationPayload
    self.signature = operationSigningResult.edsig
  }
}
