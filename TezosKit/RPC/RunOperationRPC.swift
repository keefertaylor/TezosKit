// Copyright Keefer Taylor, 2019.

import Foundation

/// An RPC that will run an operation and return fees.
public class RunOperationRPC: RPC<[String: Any]> {
  /// - Parameter operation: The operation to run.
  /// - Parameter hash: The hash of the branch to run on.
  public init(signedForgeablePayload: SignedForgeablePayload) {
    let endpoint = "chains/main/blocks/head/helpers/scripts/run_operation"
    let jsonPayload = JSONUtils.jsonString(for: signedForgeablePayload.dictionaryRepresentation)
    super.init(
      endpoint: endpoint,
      responseAdapterClass: JSONDictionaryResponseAdapter.self,
      payload: jsonPayload
    )
  }
}
