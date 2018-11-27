// Copyright Keefer Taylor, 2018

import Foundation

/**
 * An RPC which will retrieve the sum of ballots cast so far during a voting period.
 */
public class GetBallotsRPC: TezosRPC<[String: Any]> {
  /**
   * @param completion A block to be called at the completion of the operation.
   */
  public init(completion: @escaping ([String: Any]?, Error?) -> Void) {
    let endpoint = "chains/main/blocks/head/votes/ballots"
    super.init(endpoint: endpoint,
               responseAdapterClass: JSONDictionaryResponseAdapter.self,
               completion: completion)
  }
}
