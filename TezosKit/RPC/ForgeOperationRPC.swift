// Copyright Keefer Taylor, 2018

import Foundation

/// An RPC which will forge an operation.
public class ForgeOperationRPC: RPC<String> {
  /// - Parameters:
  ///   - forgeablePayload: A payload to forge.
  ///   - operationMetadata: Metadata about the operation.
  public init(
    forgeablePayload: ForgeablePayload,
    operationMetadata: OperationMetadata
  ) {
    let endpoint =
      "/chains/" + operationMetadata.chainID + "/blocks/" + operationMetadata.branch + "/helpers/forge/operations"
    let payload = JSONUtils.jsonString(for: forgeablePayload.dictionaryRepresentation)
    super.init(
      endpoint: endpoint,
      responseAdapterClass: StringResponseAdapter.self,
      payload: payload
    )
  }
}
