// Copyright Keefer Taylor, 2018

import Foundation

/**
 * An RPC which will pre-apply an operation.
 */
public class PreapplyOperationRPC: RPC<[[String: Any]]> {
  /**
   * - Parameter chainID: The chain ID to operate on.
   * - Parameter headHash: The hash of the block at the head of chain to operate on.
   * - Parameter payload: A JSON encoded string representing an operation to preapply with forged bytes.
   */
  public init(
    chainID: String,
    headHash: String,
    payload: String
  ) {
    let endpoint = "chains/" + chainID + "/blocks/" + headHash + "/helpers/preapply/operations"
    super.init(
      endpoint: endpoint,
      responseAdapterClass: JSONArrayResponseAdapter.self,
      payload: payload
    )
  }
}
