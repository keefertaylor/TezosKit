// Copyright Keefer Taylor, 2019.

import Foundation

/// An RPC that will run an operation and return fees.
public class RunOperationRPC: RPC<String> {
  /// - Parameter operation: The operation to run.
  /// - Parameter hash: The hash of the branch to run on.
  public init(operation: Operation, metadata: OperationMetadata, sig: String) {
    let endpoint = "chains/main/blocks/head/helpers/scripts/run_operation"
    var operationPayload = operation.dictionaryRepresentation
    operationPayload["counter"] = "30618"
    let payload: [String: Any] = [
      "contents": [
        operationPayload
      ],
      "branch": metadata.headHash,
    //  "protocol": metadata.protocolHash,
      "signature": sig
    ]

    let jsonPayload = JSONUtils.jsonString(for: payload)
    super.init(
      endpoint: endpoint,
      responseAdapterClass: StringResponseAdapter.self,
      payload: jsonPayload
    )
  }
}
