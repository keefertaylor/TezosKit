// Copyright Keefer Taylor, 2018

import Foundation

/**
 * An RPC which will retrieve the hash of the head of the main chain.
 */
public class GetChainHeadHashRPC: TezosRPC<String> {
  /**
   * @param completion A completion block to be called on success or failure.
   */
  public init(completion: @escaping (String?, Error?) -> Void) {
    let endpoint = "chains/main/blocks/head/hash"
    super.init(endpoint: endpoint,
               responseAdapterClass: StringResponseAdapter.self,
               completion: completion)
  }
}
