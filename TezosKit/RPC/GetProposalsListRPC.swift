// Copyright Keefer Taylor, 2018

import Foundation

/**
 * An RPC which will retrieve a list of proposals with number of supporters.
 */
public class GetProposalsListRPC: TezosRPC<[[String: Any]]> {
  /**
   * @param completion A block to be called at the completion of the operation.
   */
  public init(completion: @escaping ([[String: Any]]?, Error?) -> Void) {
    let endpoint = "chains/main/blocks/head/votes/proposals"
    super.init(endpoint: endpoint,
               responseAdapterClass: JSONArrayResponseAdapter.self,
               completion: completion)
  }
}
