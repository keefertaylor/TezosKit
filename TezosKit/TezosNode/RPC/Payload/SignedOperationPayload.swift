// Copyright Keefer Taylor, 2019.

import Foundation

/// A payload for an operation and associated signature.
public struct SignedOperationPayload {
  /// The operation payload.
  private let operationPayload: OperationPayload

  /// The signature for the operation payload.
  private let base58Signature: String

  /// Retrieve a dictionary representation of the payload.
  public var dictionaryRepresentation: [String: Any] {
    var payload = operationPayload.dictionaryRepresentation
    payload["signature"] = base58Signature
    return payload
  }

  /// - Parameters:
  ///   - operationPayload: The operation payload.
  ///   - signature: The signature for the operation payload.
  public init?(operationPayload: OperationPayload, signature: [UInt8], signingCurve: EllipticalCurve) {
    self.operationPayload = operationPayload
    guard let base58Signature = CryptoUtils.base58(signature: signature, signingCurve: signingCurve) else {
      return nil
    }
    self.base58Signature = base58Signature
  }
}
