// Copyright Keefer Taylor, 2018

import Foundation

/// An RPC which will forge an operation.
public class ForgeOperationRPC: RPC<String> {
  /// - Parameters:
  ///   - operationPayload: A payload to forge.
  ///   - operationMetadata: Metadata about the operation.
  public init(
    operationPayload: OperationPayload,
    operationMetadata: OperationMetadata
  ) {
    let endpoint =
      "/chains/main/blocks/" + operationMetadata.branch + "/helpers/forge/operations"
    let payload = JSONUtils.jsonString(for: operationPayload.dictionaryRepresentation)
    super.init(
      endpoint: endpoint,
      headers: [Header.contentTypeApplicationJSON],
      responseAdapterClass: StringResponseAdapter.self,
      payload: payload
    )
  }
}
