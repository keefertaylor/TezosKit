// Copyright Keefer Taylor, 2018

import Foundation

/**
 * An RPC which will retrieve the expected quorum.
 */
public class GetExpectedQuorumRPC: TezosRPC<String> {
  /**
   * @param blockID The level to examine the quorum at.
   * @param completion A block to be called at the completion of the operation.
   */
  public init(blockID: UInt, completion: @escaping (String?, Error?) -> Void) {
    let endpoint = "chains/main/blocks/\(blockID)/votes/current_quorum"
    super.init(endpoint: endpoint,
               responseAdapterClass: StringResponseAdapter.self,
               completion: completion)
  }
}
