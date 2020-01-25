// Copyright Keefer Taylor, 2018

import Foundation

/// An RPC which will pre-apply an operation.
public class PreapplyOperationRPC: RPC<[[String: Any]]> {
  /// - Parameters:
  ///   - signedProtocolOperationPayload: A payload to send with the operation.
  ///   - operationMetadata: Metadata about the operation to be pre-applied.
  public init(
    signedProtocolOperationPayload: SignedProtocolOperationPayload,
    operationMetadata: OperationMetadata
  ) {
    let endpoint = "/chains/main/blocks/" + operationMetadata.branch + "/helpers/preapply/operations"
    let payload = JSONUtils.jsonString(for: signedProtocolOperationPayload.dictionaryRepresentation)
    super.init(
      endpoint: endpoint,
      headers: [Header.contentTypeApplicationJSON],
      responseAdapterClass: JSONArrayResponseAdapter.self,
      payload: payload
    )
  }
}
