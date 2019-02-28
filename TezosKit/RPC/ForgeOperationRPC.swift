// Copyright Keefer Taylor, 2018

import Foundation

/// An RPC which will forge an operation.
public class ForgeOperationRPC: RPC<String> {
  /// TODO: Document.
  public init(
    operationMetadata: OperationMetadata,
    forgeablePayload: ForgeablePayload
  ) {
    let endpoint = "/chains/" + operationMetadata.chainID + "/blocks/" + operationMetadata.headHash + "/helpers/forge/operations"
    let payload = JSONUtils.jsonString(for: forgeablePayload.dictionaryRepresentation)
    super.init(
      endpoint: endpoint,
      responseAdapterClass: StringResponseAdapter.self,
      payload: payload
    )
  }
}
