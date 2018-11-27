// Copyright Keefer Taylor, 2018

import Foundation

/**
 * An RPC which will retrieve the current proposal under evaluation.
 */
public class GetProposalUnderEvaluationRPC: TezosRPC<String> {
  /**
   * @param blockID The level to examine voting rights at.
   * @param completion A block to be called at the completion of the operation.
   */
  public init(blockID: UInt, completion: @escaping (String?, Error?) -> Void) {
    let endpoint = "chains/main/blocks/\(blockID)/votes/current_proposal"
    super.init(endpoint: endpoint,
               responseAdapterClass: StringResponseAdapter.self,
               completion: completion)
  }
}
