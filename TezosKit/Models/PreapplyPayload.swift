// Copyright, Keefer Taylor 2019.

import Foundation

public class PreapplyPayload {
  private let signedForgeablePayload: SignedForgeablePayload
  private let `protocol`: String

  public var dictionaryRepresentation: [String: Any] {
    var payload = signedForgeablePayload.dictionaryRepresentation
    payload["protocol"] = `protocol`
    return payload
  }

  public init(signedForgeablePayload: SignedForgeablePayload, operationMetadata: OperationMetadata) {
    self.signedForgeablePayload = signedForgeablePayload
    self.protocol = operationMetadata.`protocol`
  }
}
