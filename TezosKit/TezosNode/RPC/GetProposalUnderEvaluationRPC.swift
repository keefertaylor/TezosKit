// Copyright Keefer Taylor, 2018

import Foundation

/// An RPC which will retrieve the current proposal under evaluation.
public class GetProposalUnderEvaluationRPC: RPC<String> {
  public init() {
    let endpoint = "chains/main/blocks/head/votes/current_proposal"
    super.init(endpoint: endpoint, responseAdapterClass: StringResponseAdapter.self)
  }
}
