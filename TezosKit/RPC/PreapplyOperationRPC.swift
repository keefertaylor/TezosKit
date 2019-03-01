// Copyright Keefer Taylor, 2018

import Foundation

/// An RPC which will pre-apply an operation.
public class PreapplyOperationRPC: RPC<[[String: Any]]> {
  /// - Parameters:
  ///   - preapplyPayload: A `PreapplyPayload` to send with the operation.
  ///   - operationMetadata: Metadata about the operation to be pre-applied.
  public init(
    preapplyPayload: PreapplyPayload,
    operationMetadata: OperationMetadata
  ) {
    let endpoint =
      "chains/" + operationMetadata.chainID + "/blocks/" + operationMetadata.branch + "/helpers/preapply/operations"
    let payload = JSONUtils.jsonString(for: [preapplyPayload.dictionaryRepresentation])
    super.init(
      endpoint: endpoint,
      responseAdapterClass: JSONArrayResponseAdapter.self,
      payload: payload
    )
  }
}
