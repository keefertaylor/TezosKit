// Copyright Keefer Taylor, 2018

import Foundation

/**
 * An RPC which will pre-apply an operation.
 */
public class PreapplyOperationRPC: TezosRPC<[[String: Any]]> {
  /**
   * @param chainID The chain ID to operate on.
   * @param headHash The hash of the block at the head of chain to operate on.
   * @param payload A JSON encoded string representing an operation to preapply with forged bytes.
   * @param completion A block to be called at completion of the operation.
   */
  public init(chainID: String,
              headHash: String,
              payload: String,
              completion: @escaping ([[String: Any]]?, Error?) -> Void) {
    let endpoint = "chains/" + chainID + "/blocks/" + headHash + "/helpers/preapply/operations"
    super.init(endpoint: endpoint,
               responseAdapterClass: JSONArrayResponseAdapter.self,
               payload: payload,
               completion: completion)
  }
}
