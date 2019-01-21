// Copyright Keefer Taylor, 2018

import Foundation

/**
 * An RPC which will retrieve a list of delegates with their voting weight, in number of rolls.
 */
public class GetVotingDelegateRightsRPC: TezosRPC<[[String: Any]]> {
  /**
   * @param completion A block to be called at the completion of the operation.
   */
  public init(completion: @escaping ([[String: Any]]?, Error?) -> Void) {
    let endpoint = "chains/main/blocks/head/votes/listings"
    super.init(endpoint: endpoint,
               responseAdapterClass: JSONArrayResponseAdapter.self,
               completion: completion)
  }
}
