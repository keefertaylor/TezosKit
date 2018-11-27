// Copyright Keefer Taylor, 2018

import Foundation

/**
 * An RPC which will retrieve ballots cast so far during a voting period.
 */
public class GetBallotsListRPC: TezosRPC<[[String: Any]]> {
  /**
   * @param completion A block to be called at the completion of the operation.
   */
  public init(completion: @escaping ([[String: Any]]?, Error?) -> Void) {
    let endpoint = "chains/main/blocks/head/votes/ballot_list"
    super.init(endpoint: endpoint,
               responseAdapterClass: JSONArrayResponseAdapter.self,
               completion: completion)
  }
}
