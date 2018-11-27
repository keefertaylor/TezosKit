// Copyright Keefer Taylor, 2018

import Foundation

/**
 * An RPC which will retrieve the expected quorum.
 */
public class GetExpectedQuorumRPC: TezosRPC<Int> {
  /**
   * @param completion A block to be called at the completion of the operation.
   */
  public init(completion: @escaping (Int?, Error?) -> Void) {
    let endpoint = "chains/main/blocks/head/votes/current_quorum"
    super.init(endpoint: endpoint,
               responseAdapterClass: IntegerResponseAdapter.self,
               completion: completion)
  }
}
