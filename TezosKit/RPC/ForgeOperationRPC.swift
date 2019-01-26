// Copyright Keefer Taylor, 2018

import Foundation

/**
 * An RPC which will forge an operation.
 */
public class ForgeOperationRPC: TezosRPC<String> {
  /**
   * @param chainID The chain which is being operated on.
   * @param headhash The hash of the head of the chain being operated on.
   * @param payload A JSON encoded string representing the operation to inject.
   * @param completion A block to call when the RPC is complete.
   */
  public init(chainID: String,
              headHash: String,
              payload: String,
              completion: @escaping (String?, Error?) -> Void) {
    let endpoint = "/chains/" + chainID + "/blocks/" + headHash + "/helpers/forge/operations"
    super.init(endpoint: endpoint,
               responseAdapterClass: StringResponseAdapter.self,
               payload: payload,
               completion: completion)
  }
}
