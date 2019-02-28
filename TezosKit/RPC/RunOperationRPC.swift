// Copyright Keefer Taylor, 2019.

import Foundation

/// An RPC that will run an operation and return fees.
public class RunOperationRPC: RPC<[String: Any]> {
  /// - Parameter operation: The operation to run.
  /// - Parameter hash: The hash of the branch to run on.
  public init(operation: Operation, contents: [[String: Any]], metadata: OperationMetadata, sig: String) {
    let endpoint = "chains/main/blocks/head/helpers/scripts/run_operation"
    var operationPayload = operation.dictionaryRepresentation
    let payload: [String: Any] = [
      "contents": contents,
      "branch": metadata.headHash,
    //  "protocol": metadata.protocolHash,
      "signature": sig
    ]

    let jsonPayload = JSONUtils.jsonString(for: payload)
    super.init(
      endpoint: endpoint,
      responseAdapterClass: JSONDictionaryResponseAdapter.self,
      payload: jsonPayload
    )
  }
}
