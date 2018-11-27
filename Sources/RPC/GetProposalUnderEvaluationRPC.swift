// Copyright Keefer Taylor, 2018

import Foundation

/**
 * An RPC which will retrieve the current proposal under evaluation.
 */
public class GetProposalUnderEvaluationRPC: TezosRPC<String> {
  /**
   * @param completion A block to be called at the completion of the operation.
   */
  public init(completion: @escaping (String?, Error?) -> Void) {
    let endpoint = "chains/main/blocks/head/votes/current_proposal"
    super.init(endpoint: endpoint,
               responseAdapterClass: StringResponseAdapter.self,
               completion: completion)
  }
}
