// Copyright Keefer Taylor, 2019.

import Foundation

/// An RPC that will run an operation and return fees.
public class RunOperationRPC: RPC<[String: Any]> {
  /// - Parameter signedOperationPayload: A payload containing an operation to run.
  public init(signedOperationPayload: SignedOperationPayload) {
    let endpoint = "chains/main/blocks/head/helpers/scripts/run_operation"
    let jsonPayload = JSONUtils.jsonString(for: signedOperationPayload.dictionaryRepresentation)
    super.init(
      endpoint: endpoint,
      responseAdapterClass: JSONDictionaryResponseAdapter.self,
      payload: jsonPayload
    )
  }
}
