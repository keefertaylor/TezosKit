// Copyright Keefer Taylor, 2019.

import Foundation
import TezosCrypto

public struct SignedForgeablePayload {
  private let forgeablePayload: ForgeablePayload
  private let signature: String

  public var dictionaryRepresentation: [String: Any] {
    var payload = forgeablePayload.dictionaryRepresentation
    payload["signature"] = signature
    return payload
  }

  public init(forgeablePayload: ForgeablePayload, operationSigningResult: OperationSigningResult) {
    self.forgeablePayload = forgeablePayload
    self.signature = operationSigningResult.edsig
  }
}
