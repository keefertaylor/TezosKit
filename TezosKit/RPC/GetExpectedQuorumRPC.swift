// Copyright Keefer Taylor, 2018

import Foundation

/// An RPC which will retrieve the expected quorum.
public class GetExpectedQuorumRPC: RPC<Int> {
  public init() {
    let endpoint = "chains/main/blocks/head/votes/current_quorum"
    super.init(endpoint: endpoint, responseAdapterClass: IntegerResponseAdapter.self)
  }
}
